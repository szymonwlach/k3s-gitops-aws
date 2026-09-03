# 01 - AWS Networking & Terraform Setup

## Problem

Homelab already proved I can run a GitOps k3s cluster — but only on local hardware.
No real cloud provisioning, no infrastructure-as-code beyond S3, no proof I can
build networking from scratch in a real cloud environment.

## Why AWS

I already have commercial hands-on experience with AWS fundamentals (S3, IAM)
from my DevOps role at Sprelli. Instead of spreading thin across multiple clouds,
I chose to go deeper into the one I already have a foundation in — AWS is also
the most commonly required cloud platform in DevOps job postings in Poland.

## Why Terraform

Manually clicking through the AWS console produces infrastructure that's hard to
reset, reproduce, or reason about. With Terraform, the entire network (VPC, subnets,
routing, security groups) can be destroyed and rebuilt identically with one command —
critical for a project I iterate on constantly while learning.

## Why k3s (not full Kubernetes or EKS)

k3s is a lightweight Kubernetes distribution — a single binary with a much smaller
resource footprint than full upstream Kubernetes. Since this cluster runs on a
small, cost-controlled EC2 instance (not enterprise-scale hardware), a lightweight
distribution was the right fit to start. A managed EKS cluster is a planned future
step once the fundamentals here are solid.

## Architecture (so far)
  
- VPC (10.0.0.0/16) with a public subnet, Internet Gateway, route table
- Security Group: SSH (22) restricted to my current IP via a dynamic Terraform
  `http` data source (no hardcoded/stale IP)
- Single EC2 instance (`t3.small`) running k3s, bootstrapped via `user_data`
- SSH key pair generated and registered entirely as code (`aws_key_pair`)

## Troubleshooting Log

**Terraform resource references** — used `aws_vpc.main` instead of `aws_vpc.main.id`
in multiple places. Terraform resource references return the whole object; explicit
`.id` is required wherever AWS expects a string identifier.

**Block vs. attribute syntax in HCL** — repeatable nested configuration (`ingress`,
`egress`, `route`) must be written as blocks (`ingress { }`), not attribute
assignments (`ingress = { }`). Made this mistake twice in two different resources
before it became a reflex.

**`user_data` runs once, on first boot only** — rebooting an existing EC2 instance
does not re-trigger `user_data`. Confirmed via `cloud-init-output.log`: a reboot
skipped both SSH host-key generation and the `scripts_user` module entirely,
proving cloud-init recognized it as the same instance, not a new one.

**Cloud-init requires a shebang at column 0** — inconsistent indentation inside a
Terraform heredoc (`<<-EOF`) left residual whitespace before `#!/bin/bash`,
which broke cloud-init's script detection silently (`Failed to run module
scripts_user`, no explicit syntax error).

**`t3.micro` was undersized for k3s** — diagnosed with `free -h` (39-66MB available
out of 914MB) and `top` (load average 4.38-8.58 on a single vCPU, 78.9% I/O wait).
k3s-server alone consumed 52% of available RAM. Root cause was resource exhaustion,
not a configuration error — resolved by resizing to `t3.small`.