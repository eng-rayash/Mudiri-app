---
trigger: always_on
---

Enterprise-grade engineering rules and architecture standards
  for the Mudiri executive management application.

globs:

- "**/*.dart"
- "**/*.yaml"
- "**/*.md"

rules:

  architecture:
    required:
      - Use Clean Architecture
      - Use Repository Pattern
      - Use Use Cases
      - Keep features modular
      - Separate layers strictly

    forbidden:
      - Business logic inside widgets
      - Direct database access from UI
      - Monolithic features
      - Random project structures

  state_management:
    required:
      framework: Riverpod

    allowed:
      - AsyncNotifierProvider
      - NotifierProvider
      - StateNotifierProvider

    forbidden:
      - GetX
      - Bloc
      - MobX
      - Legacy Provider

  database:
    orm: Drift
    encryption: SQLCipher

    required:
      - DAO per table
      - Soft Delete
      - createdAt field
      - updatedAt field
      - syncId field
      - isDeleted field
      - Migration support

    forbidden:
      - Raw SQL without reason
      - Hard Delete
      - Polymorphic relationships

  security:
    required:
      - AES256 encryption
      - flutter_secure_storage
      - Biometric authentication
      - PIN lock
      - Screenshot protection
      - Encrypted backups

    forbidden:
      - Plain-text secrets
      - Hardcoded keys
      - Unsafe exports

  ui_ux:
    design_system: Executive Neumorphism

    required:
      - Shared components
      - Centralized theme
      - RTL support
      - Arabic-first layouts
      - Responsive UI
      - Maximum 3 clicks for core actions

    forbidden:
      - Glassmorphism
      - Random colors
      - Inconsistent spacing
      - Unstructured shadows

  typography:
    fonts:
      - Tajawal
      - IBM Plex Sans Arabic

  performance:
    required:
      - Const widgets
      - Optimized rebuilds
      - Lazy loading
      - Lightweight UI
      - Efficient database queries

    forbidden:
      - Heavy build methods
      - Unnecessary rebuilds
      - Large unoptimized widgets

  clean_code:
    required:
      - SOLID principles
      - DRY principle
      - Reusable components
      - Typed code
      - Readable architecture

    forbidden:
      - Duplicate code
      - Magic numbers
      - Hardcoded strings

  naming:
    files: snake_case
    classes: PascalCase
    variables: camelCase
    methods: camelCase

  feature_structure:
    format: |
      features/
        feature_name/
          data/
          domain/
          presentation/
          providers/
          widgets/
          services/

  workflow:
    before_code:
      - Analyze feature
      - Design architecture
      - Plan database layer
      - Plan domain layer
      - Plan presentation layer
      - Plan providers
      - Plan repositories
      - Plan reusable widgets

    before_finalize:
      - Validate RTL
      - Validate performance
      - Validate security
      - Validate architecture
      - Validate design consistency
      - Validate offline support

  development_phases:
    phase_1:
      - Auth
      - Security
      - Theme
      - Dashboard
      - Meetings

    phase_2:
      - Tasks
      - Followups
      - Directives
      - Work Matrix

    phase_3:
      - Reports
      - Archive
      - Contacts
      - Appointments

    phase_4:
      - Calls
      - Visitors
      - Notes
      - Timeline

    phase_5:
      - Notifications
      - Backup
      - Export
      - Optimization
