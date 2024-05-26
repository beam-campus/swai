# Logatron Diagrams

## Description

### Minimal Viable Product

#### User Stories

_Guest_

- Sign in
- Register
- About
- Terms
- Privacy

_Known User_

  - Sing Out
  - Edit settings
  
_as a Station Owner_
---

  - Manage Stations   
    - CRUD  
    - Add devices
    - activate/deactivate
  
  - Manage Devices
    - CRUD
    - activate/deactivate
    - install Agent

## Domain Model

### Manage Stations 
```mermaid
classDiagram
  User  o-- Station : at least 1
  User: +string id 
  User: +string email
  Station o-- StationNode : at least 1
  StationNode o-- Device : exactly 1
```


