<!-- 
Sync Impact Report:
- Version change: 1.1.0 -> 1.2.0
- Added sections: Project Context, Architecture & Specifications
- Removed sections: None
- Templates requiring updates: plan-template.md, spec-template.md, tasks-template.md
- Follow-up TODOs: None
-->
# my-fullstack-app Constitution

## Core Principles

### TODO(PRINCIPLE_1): Define Principle 1
TODO(DESCRIPTION): Add principle 1 description

## Architecture & Stack Rules

1. **General Architecture (Monorepo):** 
   - The project is a Monorepo. 
   - Frontend code MUST strictly reside in `apps/frontend` (using Next.js). 
   - Backend code MUST strictly reside in `apps/backend` (using NestJS). 
   - Never mix their configurations, dependencies, or codebases.

2. **Database:** 
   - We are using PostgreSQL. 
   - All database interactions in the backend must be handled through an ORM (use Prisma or TypeORM - ask me for confirmation if needed before setting it up).

3. **Frontend Rules (`apps/frontend`):**
   - Strictly use the Next.js App Router (do not use the Pages router).
   - Use TailwindCSS for all styling and UI design.

4. **Backend Rules (`apps/backend`):**
   - Every new API Endpoint MUST have proper DTOs (Data Transfer Objects) and strict input validation.
   - All APIs must be fully documented using Swagger (OpenAPI module in NestJS).

## Project Context, Architecture & Specifications

### 1. Platform Overview & Actors
* The platform is a comprehensive Medical Lab System.
* There are three primary user roles interacting with the system: Patient, Lab Staff, and Admin.

### 2. High-Level System Architecture
* **Mobile App (Patient App):** Built using React Native or Ionic to serve patients.
* **Web Application (Lab Dashboard):** Built using Next.js (App Router) to serve Lab Staff and Admins.
* **Backend Server:** Built using NestJS, encompassing Backend Services like REST API, Authentication Service, and Booking Service.
* **AI Module:** External integrated services handling AI Recommendation and Chatbot Service.
* **Database:** PostgreSQL managed via an ORM Prisma.

### 3. Detailed Use Cases by Role
* **Patient:** Can Create Account, Login, Search Lab Tests, Compare Lab Prices, Book Appointment, Request Home Sample Collection, View Test Results, Rate Lab Service, and Ask AI Chatbot.
* **Lab Staff:** Can Manage Test Prices, Receive Bookings, and Upload Test Results.
* **Admin:** Can Approve Labs, Manage Users, Monitor Bookings, and View Platform Analytics.

### 4. Strict Database Schema Guidelines
All primary keys MUST be UUIDs. The PostgreSQL database must follow this exact schema structure:
* **Users Table:** Includes user_id (UUID), name, email, password, and role.
* **Labs Table:** Includes lab_id (UUID), name, address, and phone.
* **Tests Table:** Includes test_id (UUID) and name.
* **Lab_Tests (Junction Table):** Includes id, lab_id, test_id, and price.
* **Bookings Table:** Includes booking_id (UUID), user_id, lab_id, status, and scheduled_at.
* **Booking_Tests (Junction Table):** Includes id, booking_id, and lab_test_id.
* **Results Table:** Includes result_id (UUID), booking_id, and pdf_path.
* **Ratings Table:** Includes rating_id (UUID), user_id, lab_id, and stars.

### 5. Spec Kit Agent Directives
* Before generating any `/speckit.plan`, you MUST cross-reference the feature requested with the above Database Schema and Use Cases.
* If a backend API is generated, you MUST ensure the DTOs match the exact fields specified in the schema.
* Keep Frontend Web (Next.js), Frontend Mobile (React Native/Ionic), and Backend (NestJS) concerns strictly separated within the monorepo.

## Governance

Amendments require documentation, approval, and a migration plan. All PRs/reviews must verify compliance.

**Version**: 1.2.0 | **Ratified**: TODO(DATE) | **Last Amended**: 2026-03-14
