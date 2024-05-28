# Swai.Born2Died Subsystem

The Swai.Born2Died subsystem is responsible for controlling and simulating the Born2Died of farm animal.

## Outline

- [Swai.Born2Died Subsystem](#swaiborn2died-subsystem)
  - [Outline](#outline)
  - [Diagrams](#diagrams)
    - [Actor diagram](#actor-diagram)
    - [Sequence diagram](#sequence-diagram)
  - [References](#references)
    - [Whiteboard](#whiteboard)

## Diagrams  

### Actor diagram

```mermaid
graph TD

  System[Born2Died.System]
  Supervisor[Born2Died.System.Supervisor]
  Worker[Born2Died.HealthWorker]
  Channel[Swai.Born2Died.HealthEmitter]

  System --> |start_link| Supervisor  
  Supervisor --> |start_child| Worker
  Supervisor --> |start_child| Channel

```

### Sequence diagram

```mermaid
sequenceDiagram
  participant Born2Died.System
  participant Born2Died.Supervisor
  participant Born2Died.HealthWorker
  participant Born2Died.HealthEmitter

  Born2Died.System->>Born2Died.Supervisor : start_link(Born2Died_id)

```

## References

### Whiteboard

A whiteboard for this project can be found [here](https://lucid.app/lucidspark/3df9ee41-a400-404e-88e7-077037985398/edit?viewport_loc=-11012%2C-327%2C1280%2C662%2C0_0&invitationId=inv_46688d00-55d4-4cf8-8006-bcd038eed321)
