# JDP Financial Framework - Quick Start Implementation Guide

## Executive Summary

This framework enables comprehensive financial tracking with:

- **PTX Funding Format** (PTX10001, PTX10002, etc.)
- **Many-to-Many Relationships** between PTX funds and Ideas/Bets/Enablers
- **Complete Delivery Hierarchy** with automatic roll-ups
- **External Time System Integration** for accurate cost tracking
- **Multi-dimensional Budgeting** by Business Unit and Initiative

-----

## 1. Day 1: Understanding the Core Concept

### The PTX Funding Model

```
One PTX → Many Projects:
PTX10001 ($5M) ──┬──► IDEA-001 (40% = $2M)
                 ├──► IDEA-002 (35% = $1.75M)
                 └──► IDEA-005 (25% = $1.25M)

One Project → Many PTX:
IDEA-001 ($5.45M) ◄──┬── PTX10001 (40% = $2.18M)
                     ├── PTX10002 (30% = $1.64M)
                     └── PTX10003 (30% = $1.64M)
```

### The Complete Hierarchy

```
PTX Funding → Ideas → Work Items → Capabilities → Features → Stories → Time Entries
     ↓          ↓          ↓            ↓            ↓          ↓           ↓
  Budget    Strategy   Delivery    T-Shirt XXL    T-Shirt L   Points    Hours×Rate
```

-----

## 2. Week 1: Initial Setup

### Step 1: Configure PTX Codes

```csv
PTX10001,Enterprise Digital Fund,Finance,5000000
PTX10002,Technology Modernization,Technology,8000000
PTX10003,Customer Experience,Marketing,3500000
PTX20001,Infrastructure Investment,Operations,6000000
```

### Step 2: Map Ideas to PTX (Many-to-Many)

```csv
IDEA-001,Digital Customer Platform,PTX10001:40%,PTX10002:30%,PTX10003:30%
IDEA-002,AI Analytics,PTX10001:35%,PTX20002:70%
IDEA-003,Cloud Infrastructure,PTX10002:50%,PTX20001:60%
```

### Step 3: Set Up Work Item Hierarchy

```yaml
IDEA-001: Digital Customer Platform
├── WI-001: Bet - Mobile Platform (380 points, XXL)
├── WI-002: Solution - Customer Portal (320 points, XXL)
├── WI-003: Enabler - API Gateway (280 points, XXL)
└── WI-004: Experiment - Voice UI POC (80 points, L)
```

-----

## 3. Week 2: Delivery Hierarchy Setup

### Capability → Feature → Story Structure

```yaml
Capability: Mobile User Experience (XXL, 380 points)
├── Feature: iOS Mobile App (L, 45 points)
│   ├── Story: User Login (S, 5 points, 40 hours)
│   ├── Story: Registration (S, 8 points, 64 hours)
│   └── Story: Password Reset (XS, 3 points, 24 hours)
├── Feature: Android App (L, 45 points)
└── Feature: Progressive Web App (L, 40 points)
```

### T-Shirt Sizing Rules

|Size|Points |Cost Range|Use Case        |
|----|-------|----------|----------------|
|S   |3-8    |$3.6K-9.6K|Single Story    |
|L   |34-55  |$40K-66K  |Feature         |
|XL  |89-144 |$106K-173K|Small Capability|
|XXL |233-377|$280K-452K|Full Capability |

-----

## 4. Week 3: External Time Integration

### Connect Time Tracking System

```json
{
  "time_entry": {
    "employee": "John Smith",
    "team": "Mobile Team Alpha",
    "hours": 8,
    "rate": 165,
    "story_id": "STY-001",
    "charge_code": "CC-PTX10001-MOB"
  }
}
```

### Automatic Roll-up Chain

```
8 hours logged → Story (STY-001) → Feature (FEA-001) → 
Capability (CAP-001) → Work Item (WI-001) → Idea (IDEA-001) → 
PTX Allocation (PTX10001: 40%, PTX10002: 30%, PTX10003: 30%)
```

### Cost Calculation

```
8 hours × $165/hour = $1,320
CapEx (60%): $792
OpEx (40%): $528

PTX10001 charge: $528 (40% of $1,320)
PTX10002 charge: $396 (30% of $1,320)
PTX10003 charge: $396 (30% of $1,320)
```

-----

## 5. Week 4: Reporting Setup

### Monthly PTX Performance Report

```yaml
PTX10001 - March 2024:
  Budget: $5,000,000
  Consumed: $208,000
  Monthly Burn: $208,000
  
  Delivery:
    Stories Completed: 15
    Points Delivered: 85
    Velocity: 85 points/month
    
  Distribution:
    IDEA-001: $83,200 (40%)
    IDEA-002: $72,800 (35%)
    IDEA-005: $52,000 (25%)
    
  CapEx/OpEx:
    CapEx: $124,800 (60%)
    OpEx: $83,200 (40%)
```

### Business Unit Chargeback

```yaml
Finance Department - March 2024:
  PTX Codes: [PTX10001]
  Total Charged: $208,000
  
  By Project:
    IDEA-001: $83,200
    IDEA-002: $72,800
    IDEA-005: $52,000
    
  By Type:
    Development: $165,000
    Infrastructure: $43,000
```

-----

## 6. Key Formulas for PMs

### Story Point Roll-up

```sql
Feature.points = SUM(Story.points)
Capability.points = SUM(Feature.points)
WorkItem.points = SUM(Capability.points)
Idea.points = SUM(WorkItem.points)
```

### Cost Roll-up

```sql
Story.cost = Hours × Team_Rate
Feature.cost = SUM(Story.cost)
Capability.cost = SUM(Feature.cost)
WorkItem.cost = SUM(Capability.cost)
Idea.cost = SUM(WorkItem.cost)
```

### PTX Allocation

```sql
PTX10001.charge = Idea.cost × 0.40  -- 40% allocation
PTX10002.charge = Idea.cost × 0.30  -- 30% allocation
PTX10003.charge = Idea.cost × 0.30  -- 30% allocation
```

### Velocity Calculation

```sql
Team.velocity = Points_Completed / Sprints
Remaining_Sprints = Points_Remaining / Team.velocity
Completion_Date = Today + (Remaining_Sprints × 14 days)
```

-----

## 7. Common Scenarios

### Scenario A: Multiple Ideas Using Same PTX

```yaml
PTX10001 funds:
  - IDEA-001: 40% ($2M)
  - IDEA-002: 35% ($1.75M)  
  - IDEA-005: 25% ($1.25M)
Total: 100% ($5M)
```

### Scenario B: Single Idea, Multiple PTX Sources

```yaml
IDEA-001 funded by:
  - PTX10001: 40% ($2.18M)
  - PTX10002: 30% ($1.64M)
  - PTX10003: 30% ($1.64M)
Total: $5.45M
```

### Scenario C: Enabler Shared Across Ideas

```yaml
ENABLER-001 (API Gateway):
  Supports: IDEA-001, IDEA-002, IDEA-003
  Funding: PTX10002 (100%)
  Cost Allocation:
    - IDEA-001: 40%
    - IDEA-002: 35%
    - IDEA-003: 25%
```

-----

## 8. Data Entry Templates

### For PMs - Simple Entry

```csv
# ideas_simple.csv
idea_id,ptx_codes,budget,capex%,opex%,points
IDEA-010,PTX10001:60%;PTX10002:40%,1500000,60,40,450
```

### For PMs - Detailed Entry

```csv
# work_items_detailed.csv
item_id,type,parent_idea,ptx,budget,points,t_shirt
WI-020,Bet,IDEA-010,PTX10001;PTX10002,500000,150,XL
WI-021,Solution,IDEA-010,PTX10001,400000,120,XL
WI-022,Enabler,IDEA-010,PTX10002,350000,100,L
```

### For Teams - Time Entry

```csv
# time_entries.csv
date,employee,team,story_id,hours,charge_code
2024-03-15,John Smith,Mobile Alpha,STY-001,8,CC-PTX10001-MOB
```

-----

## 9. Validation Checklist

### Daily

- [ ] Time entries synced from external system
- [ ] Story status updates reflected
- [ ] Charge codes mapped correctly

### Weekly

- [ ] Story points completed updated
- [ ] Velocity calculations current
- [ ] PTX consumption tracking accurate

### Monthly

- [ ] CapEx/OpEx split validated
- [ ] Business unit chargebacks calculated
- [ ] PTX allocation percentages = 100%
- [ ] Roll-up calculations verified

-----

## 10. Quick Reference

### Critical Rules

1. **PTX Allocation**: Must always total 100% for each Idea
1. **Many-to-Many**: Single PTX can fund multiple Ideas; Single Idea can have multiple PTX
1. **Roll-ups**: Automatic from Story → Feature → Capability → Work Item → Idea → PTX
1. **Time Integration**: External hours × rate = cost → allocated by PTX percentages
1. **T-Shirt Sizing**: Based on total story points at each level

### Support Contacts

- **Finance**: PTX allocation questions
- **PMO**: Framework and process
- **IT**: External system integration
- **Analytics**: Report generation

### Common PTX Codes

```
PTX10xxx - Finance initiatives
PTX20xxx - Technology/Infrastructure  
PTX30xxx - Security/Compliance
PTX40xxx - Innovation/R&D
```

-----

## Success Metrics

|Metric              |Target       |Current       |
|--------------------|-------------|--------------|
|PTX Utilization     |>90%         |Track monthly |
|Story Point Velocity|±10% variance|Per team      |
|Time Entry Lag      |<24 hours    |Daily check   |
|Roll-up Accuracy    |100%         |Weekly audit  |
|CapEx/OpEx Accuracy |±5%          |Monthly review|

-----

*Start with one Idea, add Work Items, then Capabilities. The system will handle all roll-ups automatically!*