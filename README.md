# SQL-Project

Introduction
All Universities require a significant information infrastructure in order to manage their affairs. This typically involves a large commercial DBMS installation. UNSW's student information system sits behind the MyUNSW web site. MyUNSW provides an interface to a PeopleSoft enterprise management system with an underlying Oracle database. This back-end system (Peoplesoft/Oracle) is often called NSS.
UNSW has spent a considerable amount of money ($80M+) on the MyUNSW/NSS system, and it handles much of the educational administration plausibly well. Most people gripe about the quality of the MyUNSW interface, but the system does allow you to carry out most basic enrolment tasks online.
  
Despite its successes, MyUNSW/NSS still has several deficiencies, including:
• no waiting lists for course or class enrolment
• no representation for degree program structures
• poor integration with the UNSW Online Handbook
The first point is inconvenient, since it means that enrolment into a full course or class becomes a sequence of trial-and-error attempts, hoping that somebody has dropped out just before you attempt to enroll and that no-one else has grabbed the available spot.
The second point prevents MyUNSW/NSS from being used for three important operations that would be extremely helpful to students in managing their enrolment:
• finding out how far they have progressed through their degree program, and what remains to be completed
• checking what are their enrolment options for next semester (e.g., get a list of available courses)
• determining when they have completed all the requirements of their degree program and are eligible to graduate
NSS contains data about student, courses, classes, pre-requisites, quotas, etc. but does not contain any representation of UNSW's degree program structures. Without such information in the NSS database, it is not possible to do any of the above three. So, in 2007 the COMP9311 class devised a data model that could represent program requirements and rules for UNSW degrees. This was built on top of an existing schema that represented all the core NSS data (students, staff, courses, classes, etc.). The enhanced data model was named the MyMyUNSW schema.
The MyMyUNSW database includes information that encompasses the functionality of NSS, the UNSW Online Handbook, and the CATS (room allocation) database. The MyMyUNSW data model, schema and database are described in a separate document.


Project Purpose


The MyMyUNSW database project aims to enhance the functionality and usability of UNSW's student information system by addressing existing deficiencies and providing solutions to common challenges faced by students and staff. By leveraging the enhanced data model and SQL queries, the project seeks to streamline processes such as course enrollment, degree program tracking, and integration with other university systems.



