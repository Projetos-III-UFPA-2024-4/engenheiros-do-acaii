# Engenheiros-do-açaíi
Repositório da equipe Engenheiros do açaíi criado para a matéria de Projetos 3 do curso de Engenharia da Computação pela Universidade Federal do Pará.
## Integrantes:
- David Sousa
- Giulia Faria
- Giovanna Cunha
- Thalia Ramos

SmartVolt is an intelligent Service-Oriented Architecture (SOA) platform designed to integrate real-time solar generation and consumption data. Developed by the Engenheiros do Açaí team, the system provides users with clear insights and predictive analytics to optimize energy management and reduce costs.

# Key Features
- Real-time Integration: Synchronizes data from three-phase bidirectional meters and solar inverters via HTTP.
- Advanced Forecasting: Dual time-series models (Prophet) predict both energy consumption and photovoltaic production.
- Smart Economics: Helps users adjust behavior to avoid surplus charges and maximize savings on energy bills.
- Interactive Mobile Experience: A Flutter-based application offering intuitive dashboards and real-time alerts.

# System Architecture (SOA)
The system is built on a Service-Oriented Architecture using RESTful APIs for seamless component communication.

1. Hardware Integration Layer
SM-3W Lite Meter: Collects bidirectional energy data (consumption/generation) and transmits it via HTTP.

Deye SUN Inverter: Monitors AC energy conversion and sends production metrics to the backend.

2. Backend & Intelligence Layer
CRUD Data Service: Manages and organizes the storage of measurement and prediction data.

MySQL Database: Features dedicated tables for Real-time Consumption/Production and Predicted Consumption/Production.

AI Models (Facebook Prophet):

Consumption Model: Trained on historical usage patterns.

Production Model: Utilizes historical generation data and meteorological variables like solar radiation.

3. Mobile Frontend
Technology: Built with Flutter.

Function: Consumes backend APIs to deliver real-time monitoring and interactive forecasting visualizations to the end-user.


# Tech Stack
Languages: Python (AI/Scripts), Java/Node.js (Backend), Dart (Mobile).

Frameworks: Flutter, Express/Spring (REST APIs), Flask (AI serving).

Machine Learning: Facebook Prophet for time-series forecasting.

Database: MySQL.
