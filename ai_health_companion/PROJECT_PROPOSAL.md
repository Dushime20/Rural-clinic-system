# Project Proposal: AI-Powered Community Health Companion for Clinical Decision Support and Pharmacy Integration in Rwanda

## Executive Summary

The Rwandan healthcare system stands at a critical inflection point. While the nation has achieved globally recognized success in establishing a robust primary healthcare foundation through its network of Community Health Workers (CHWs), the epidemiological landscape is shifting. The rising prevalence of Non-Communicable Diseases (NCDs) now accounts for a significant portion of mortality, creating a "diagnostic gap" that the current protocol-based community care model struggles to bridge.

This proposal outlines a final year academic project by a team of three students to design and prototype the **AI-Powered Community Health Companion**. This digital health solution serves as a Clinical Decision Support System (CDSS) tailored for Rwanda's CHWs. Unlike complex national telemedicine projects, this student initiative focuses on a lean, "integration-ready" prototype that leverages "Tiny AI" (Edge Computing) to function offline on mobile devices.

The system combines the diagnostic capabilities of Large Language Models (LLMs) trained on the DDXPlus dataset with the local context of the AfriMedQA benchmark. To address the economic burden of "pharmacy hopping," the application will include a module designed to query the Electronic Logistics Management Information System (e-LMIS) for real-time medication availability.

This project is strictly scoped for completion within **3.5 months**. It aims to deliver a functional proof-of-concept that demonstrates how AI can augment CHW capabilities and how interoperability with pharmacy systems can optimize care logistics. The proposed budget is minimal, focusing strictly on the resources required to develop, test, and defend the project academically.

---

## Chapter 1: Strategic Context and Problem Diagnosis

### 1.1 Background and Motivation

Rwanda's health sector has made tremendous strides, particularly in maternal and child health, driven by the dedication of over 58,000 CHWs. However, as the burden of disease shifts towards complex conditions like hypertension and diabetes, CHWs facing these new challenges often lack the advanced diagnostic tools required for early detection.

For rural patients, this "diagnostic gap" often results in delayed care. Furthermore, patients frequently face the "pharmacy supply chain disconnect," where they travel to health facilities only to find essential medications out of stock. This project seeks to address these specific pain points through a student-led technical innovation.

### 1.2 Statement of the Problem

Despite the reach of the CHW network, three core issues persist:

1. **Limited Diagnostic Support**: CHWs rely on paper-based algorithmic protocols which are insufficient for complex or ambiguous symptoms, particularly for NCDs.

2. **Pharmacy Hopping**: There is no tool at the community level to check if a prescribed medication is available at the nearest health center, leading to wasted travel and costs for patients.

3. **Connectivity Barriers**: Existing cloud-based AI tools fail in rural Rwanda due to intermittent internet connectivity (approx. 19% rural penetration).

### 1.3 Project Objectives

The primary objective is to develop a functional prototype of the AI Health Companion within an academic timeframe of 3.5 months.

- **Develop an Offline AI Triage Engine**: Create a mobile app using "Tiny AI" (TensorFlow Lite) that offers diagnostic suggestions without requiring active internet.
- **Implement Pharmacy Interoperability Layers**: Build the system to be "integration-ready" for the national e-LMIS system, allowing for stock availability checks.
- **Ensure Accessibility**: Integrate the Mbaza NLP engine to demonstrate voice-based data entry in Kinyarwanda.

---

## Chapter 2: Technical Solution: The AI Health Companion

### 2.1 Solution Overview

The solution is a mobile-based Android application designed to assist CHWs. To ensure feasibility for a final year project, the scope has been streamlined to focus on two core value propositions: **AI-Assisted Triage** and **Pharmacy Availability Checks**.

#### Table 2.1: Core Functional Modules (Student Scope)

| Module Name | Functionality | User Benefit |
|-------------|---------------|--------------|
| Assisted Triage (AI Engine) | Analyzes reported symptoms to generate a ranked list of potential conditions. | Augments CHW decision-making for complex cases. |
| Pharmacy Check (e-LMIS Ready) | Simulates queries to the national e-LMIS to check for medication stock status. | Prevents "pharmacy hopping" by confirming stock before travel. |
| Voice Interface (Mbaza NLP) | Enables speech-to-text interaction in Kinyarwanda. | Increases accessibility for users with lower digital literacy. |
| Offline Manager | Manages local SQLite database for offline functionality. | Ensures the app works in remote areas without internet. |

### 2.2 Artificial Intelligence Architecture

The intelligence core utilizes a "Tiny AI" approach to run efficiently on standard mobile devices used for testing.

- **Model Training**: The team will utilize the DDXPlus dataset (1.3 million patient records) to train a foundational diagnostic model. This model will be fine-tuned using the AfriMedQA dataset to ensure relevance to African clinical presentations.

- **Edge Deployment**: The trained model will be quantized (compressed) and converted to TensorFlow Lite. This allows the inference to happen directly on the student's demo device, removing the need for expensive GPU cloud servers during the defense.

### 2.3 User Interaction Design

- **CHW Mode**: The primary interface for the project. It allows the user to register a patient (locally), input symptoms via voice or text, and receive a probabilistic diagnosis.

- **Voice Integration**: Using the open-source Mbaza NLP API, the app will support Kinyarwanda voice input, which is a critical feature for local adoption.

---

## Chapter 3: System Architecture

### 3.1 High-Level Architecture

The system follows a microservices architecture tailored for student budget. Instead of expensive local data centers, the backend will be hosted on cost-effective cloud platforms.

#### Table 3.1: Technology Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| Mobile Frontend | Flutter (Dart) | Single codebase for Android; excellent offline support. |
| AI Engine | Python / TensorFlow Lite | Industry standard for training and mobile deployment. |
| Backend API | Node.js / Express | Lightweight, easy to deploy on free/cheap cloud tiers. |
| Database | Firebase / MongoDB | Flexible NoSQL storage for the prototype backend. |
| Hosting | Cloud Provider (e.g., Render/Heroku) | Cost-effective hosting solution for the project duration. |

### 3.2 Interoperability Strategy

**Focus: e-LMIS Integration Readiness**

- **Simulation**: We will build a "Mock e-LMIS" API that replicates the data structure of the real national system. This allows us to demonstrate the functionality of checking medicine stock (e.g., querying if "Amoxicillin" is available at "Kigali Health Center") without needing government security clearance for the live system.

- **Standardization**: The API calls will be structured according to OpenHIE standards, proving that the system is technically ready to be plugged into the real e-LMIS in a future phase.

---

## Chapter 4: Implementation Methodology

### 4.1 Project Timeline (3.5 Months)

The project will follow an Agile methodology, broken down into 2-week sprints to ensure rapid development and testing within the tight deadline.

#### Phase 1: Research & Design (Weeks 1-4)
- Requirement gathering
- System architecture design (UML diagrams)
- UI/UX prototyping (Figma)
- **Deliverable**: System Design Document

#### Phase 2: Development (Weeks 5-10)
- **Sprint 1**: Set up Flutter environment and build UI skeleton
- **Sprint 2**: Train AI model on DDXPlus/AfriMedQA and convert to TFLite
- **Sprint 3**: Implement Mbaza NLP voice features
- **Sprint 4**: Develop Backend API and Mock e-LMIS for pharmacy checking
- **Deliverable**: Functional MVP (Minimum Viable Product)

#### Phase 3: Testing & Finalization (Weeks 11-14)
- System testing (Unit testing, Integration testing)
- Usability testing (with peers or a small group of users)
- Final Report writing and preparation for defense
- **Deliverable**: Final Report and Demo Application

---

## Chapter 5: Legal and Ethical Considerations

### 5.1 Regulatory Alignment

While this is an academic prototype, the design adheres to the principles of Law No 026/2025 regarding healthcare regulation.

- **Decision Support vs. Diagnosis**: The app explicitly labels AI outputs as "recommendations" to be verified by a human, avoiding the legal liability of automated diagnosis.

- **Data Privacy**: Even as a prototype, the app implements data encryption (AES-256) for local storage, demonstrating awareness of the Data Protection and Privacy Law.

### 5.2 AI Ethics

To mitigate bias, the model is fine-tuned on AfriMedQA, ensuring it recognizes disease presentations common in the African context rather than just Western datasets. This addresses the ethical imperative of algorithmic fairness.

---

## Chapter 6: Operational Impact

### 6.1 Monitoring, Evaluation, and Learning (MEL)

For our project, success will be measured by:

- **Functional Success**: The ability of the app to function 100% offline for diagnosis
- **Accuracy**: The AI model achieved a top-3 accuracy rate of >80% on the validation dataset
- **Latency**: Inference time on the mobile device being under 2 seconds to ensure usability

### 6.2 Economic Sustainability (Theoretical)

The project demonstrates economic viability by using open-source tools (Flutter, TensorFlow) and low-cost cloud hosting. If scaled, the reduction in "pharmacy hopping" costs for patients would theoretically offset the operational costs of the system.

---

## Chapter 7: Resource Planning and Budget

### 7.1 Resource Requirements

The project team consists of 3 Students. No external hiring is required.

- **Student 1**: Backend & Database / API Integration
- **Student 2**: Mobile App Development (Flutter) / UI/UX
- **Student 3**: AI Model Training / Data Science / Documentation

### 7.2 Estimated Budget

The budget is optimized for a student team, utilizing existing resources (personal laptops) and free-tier services where possible.

#### Table 7.2: Project Budget (3.5 Months)

| Cost Category | Description | Estimated Cost (RWF) | Estimated Cost (USD) |
|---------------|-------------|---------------------|---------------------|
| Internet Data | High-speed 4G/Fiber bundles for 3 students (3.5 months) | 120,000 RWF | ~$100 |
| Cloud Hosting | Hosting for Backend/Database (e.g., VPS or Paid Tier if needed) | 60,000 RWF | ~$50 |
| Printing/Binding | Final Report printing and defense materials | 50,000 RWF | ~$40 |
| Miscellaneous | Transport to meetings, minor contingencies | 60,000 RWF | ~$50 |
| **TOTAL** | | **~290,000 RWF** | **~$240** |

### 7.3 Conclusion

This final year project proposes a feasible, high-impact technical solution to real-world health challenges in Rwanda. By stripping away administrative complexity and focusing on "Tiny AI" and pharmacy interoperability, the team will demonstrate a working prototype that aligns with Rwanda's Vision 2050 and HSSP V goals. The resulting application will serve as a testament to the potential of student-led innovation in bridging the gap between advanced technology and community health needs.

---

## Works Cited

1. National Institute of Statistics of Rwanda. Rwanda Demographic and Health Survey.
2. How Good Are Large Language Models at Supporting Frontline Healthcare Workers in Low-Resource Settings? (AfriMedQA).
3. Digital Umuganda. Mbaza NLP Community.
4. Ministry of Health. National Digital Health Strategic Plan.
5. Parliament of Rwanda. Law No 026/2025 Regulating Healthcare Services.
6. TensorFlow. TensorFlow Lite for Mobile Devices.
7. Law No 058/2021 relating to the protection of personal data and privacy.

## References

1. [Health Sector Strategic Plan V - MOH-Rwanda](https://www.moh.gov.rw/index.php?eID=dumpFile&t=f&f=117507&token=f2a527e089201f73bec29f8ce6d6c4dc55ed241e)
2. [In Rwanda, Voice Technology Innovation Helps Fight COVID - Mozilla Foundation](https://www.mozillafoundation.org/es/blog/in-rwanda-voice-technology-innovation-helps-fight-covid/)
3. [The National Digital Health Strategic Plan 2018-2023 - Extranet Systems](https://extranet.who.int/countryplanningcycles/sites/default/files/public_file_rep/RWA_Rwanda_Digital-Health-Strategy_2018-2023.Pdf)
4. [Center Drives Landmark Law Expanding Health Care Access for Adolescents in Rwanda](https://reproductiverights.org/news/center-drives-landmark-law-expanding-adolescent-health-care-access-rwanda/)
5. [A Case Study in Local Content Hosting: Speed, Visits, and Cost of Access - Internet Society](https://www.internetsociety.org/resources/doc/2017/a-case-study-in-local-content-hosting-speed-visits-and-cost-of-access/)
6. [Protection of Personal Data and Cybersecurity: Top Priorities in Rwanda's Digital Transformation journey - RISA](https://www.risa.gov.rw/news-detail/protection-of-personal-data-and-cybersecurity-top-priorities-in-rwandas-digital-transformation-journey)

---

**Project Team**: 3 Students  
**Duration**: 3.5 Months  
**Budget**: ~$240 USD  
**Target Platform**: Android (Flutter)  
**Key Technologies**: TensorFlow Lite, Flutter, Node.js, Mbaza NLP
