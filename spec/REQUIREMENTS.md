# Deevnet Builder Ansible Collection  
## Functional and Non-Functional Requirements

---

## 0. Assumptions and Operating Model

The following assumptions apply unless explicitly overridden:

- Target systems are **Fedora-based** server or workstation installations.
- Target systems are **Ansible-ready**, with:
  - Python installed
  - SSH access available
  - The `a_autoprov` public SSH key pre-deployed
- Hosts are provisioned from a known-good baseline image.
- This collection is applied to **trusted internal systems**.
- The collection is executed with sufficient privileges to configure system services.

This collection **does not build OS images**.  
OS image creation is handled by **`deevnet-image-factory`**.

---

## 1. Functional Requirements (FR)

### FR-1: Baseline Builder Host Configuration
The collection **MUST** support establishing a minimal baseline suitable for builder and bootstrap roles.

Sub-functions:
- Establish a predictable system state for subsequent roles
- Ensure required system capabilities are present
- Apply safe, repeatable configuration

---

### FR-2: Artifact Acquisition and Distribution Role
The collection **MUST** support acquiring and distributing artifacts required by the Deevnet ecosystem.

Sub-functions:
- Retrieve externally hosted artifacts
- Retrieve internally hosted artifacts
- Store artifacts in a consistent, discoverable structure
- Optionally expose artifacts over a local network
- Support secure access to artifacts where required

Artifacts may include:
- OS installation media
- Netboot assets
- Container images
- Collection and tooling artifacts

---

### FR-3: Bootstrap and Netboot Services Role
The collection **MUST** support configuring a host capable of bootstrapping other systems.

Sub-functions:
- Provide network services required for initial host bootstrapping
- Serve boot images and configuration data
- Support unattended system initialization
- Operate correctly in SELinux-enabled environments
- Integrate with existing network security controls

---

### FR-4: Containerized Infrastructure Service Role
The collection **MUST** support running internal infrastructure services using containers.

Sub-functions:
- Acquire container images
- Persist service data across restarts
- Ensure services start automatically on boot
- Integrate with system security and firewall controls
- Allow services to be upgraded or replaced safely

---

### FR-5: Builder and Admin Workstation Role
The collection **MUST** support configuring systems used by administrators and builders.

Sub-functions:
- Provide developer tooling
- Provide infrastructure tooling
- Support virtualization workflows
- Support AI-assisted development workflows
- Support consistent user account provisioning

---

### FR-6: Role Composition and Host Profiles
The collection **MUST** support composing multiple roles into defined host profiles.

Sub-functions:
- Enable hosts to serve one or more functions
- Allow selective role application
- Support future profile expansion

Example profiles:
- Artifact Host
- Bootstrap Host
- Infrastructure Controller Host
- Builder / Admin Workstation

---

### FR-7: Orchestration and Entry Points
The collection **MUST** provide a clear entry point for applying roles.

Sub-functions:
- Support full and partial deployments
- Support non-interactive execution
- Support predictable ordering of operations

---

### FR-8: Dependency Declaration and Resolution
The collection **MUST** explicitly declare all external dependencies.

Sub-functions:
- Support reproducible dependency installation
- Avoid reliance on system-wide implicit dependencies
- Support both project-local and user-local dependency resolution

---

### FR-9: Local-Only Installation Model
The collection **MUST** support development and use without installing itself system-wide.

Sub-functions:
- Support project-local installation
- Support user-local installation
- Prevent accidental system-wide installation

---

### FR-10: Collection Packaging and Distribution
The collection **MUST** support packaging itself as a distributable artifact.

Sub-functions:
- Produce versioned collection artifacts
- Support local artifact distribution
- Support offline or low-connectivity environments

---

## 2. Non-Functional Requirements (NFR)

### NFR-1: Idempotency
Repeated execution **MUST NOT** produce unintended changes.

---

### NFR-2: Reproducibility
Given the same inputs, the same outcomes **MUST** be produced.

---

### NFR-3: Separation of Concerns
The collection **MUST NOT** assume responsibilities belonging to:
- Image creation
- Application runtime deployment
- Cloud provisioning

---

### NFR-4: Security Awareness
The collection **MUST**:
- Avoid embedding secrets
- Support external secret sources
- Operate safely in trusted internal environments

---

### NFR-5: Minimal Assumptions
The collection **MUST**:
- Avoid unnecessary platform coupling
- Operate correctly on headless systems
- Favor server-grade defaults

---

### NFR-6: Extensibility
New roles and capabilities **MUST** be addable without breaking existing users.

---

### NFR-7: Transparency
Configuration **MUST** be explicit and understandable.

---

### NFR-8: Developer Experience
The collection **SHOULD**:
- Support iterative development
- Provide clear Makefile targets
- Encourage safe experimentation

---

## 3. Out of Scope

- OS image construction
- End-user desktop personalization
- Production application hosting
- Cloud-specific provisioning

---

## 4. Success Criteria

This collection is successful when:
- Builder and bootstrap hosts can be provisioned from a known baseline
- Artifact distribution is reliable and repeatable
- PXE/bootstrap services operate predictably
- No system-wide Ansible pollution occurs

---

## 5. Notes

This document defines **intent**, not implementation.  
Implementation details are deliberately deferred.
