# Business Analyst Portfolio - Oregon Cannabis Market Intelligence Platform

## Project Overview

**Project Name:** Oregon Cannabis Market Intelligence Platform  
**Role:** Business Analyst / Data Analyst  
**Duration:** 2026  
**Tools:** Python, PostgreSQL, SQL, Tableau, Geocoding APIs  
**Domain:** CPG Industry, Market Intelligence, Geographic Analysis

---

## Executive Summary

Developed a comprehensive market intelligence platform that integrates Oregon Liquor Control Commission (OLCC) retailer data with geographic analysis and competitive intelligence. This platform enables data-driven territory planning, market expansion decisions, and strategic sales optimization for CPG companies operating in the Oregon cannabis market.

**Key Achievements:**
- Processed and validated 761 retailer records with 100% address parsing accuracy
- Implemented geocoding for all locations enabling spatial analysis
- Created integrated data model supporting multi-dimensional market analysis
- Designed three strategic Tableau dashboards for business intelligence
- Demonstrated end-to-end data pipeline from raw data to actionable insights

---

## Business Problem

### Challenge
Oregon cannabis market lacked comprehensive, actionable intelligence for strategic planning. Companies struggled with:
- Understanding retailer distribution and competitive landscape
- Identifying optimal territories for sales expansion
- Making data-driven decisions about market entry and resource allocation
- Analyzing geographic patterns and market saturation

### Impact
Without market intelligence, companies faced:
- Inefficient territory planning and resource allocation
- Missed opportunities in high-potential markets
- Competitive disadvantage in strategic positioning
- Inability to quantify market opportunity and risk

---

## Solution Approach

### Data Integration Strategy
Built a comprehensive data pipeline integrating multiple data sources:

1. **OLCC Retailer Data**
   - Source: Oregon Liquor Control Commission public records
   - Volume: 761 active retailer licenses
   - Scope: Statewide coverage across 30 counties, 115 cities

2. **Geographic Data**
   - Geocoding: 100% success rate using Nominatim API
   - Spatial calculations: Distance analysis, regional clustering
   - Geographic hierarchy: State → County → City → Address

3. **Market Intelligence**
   - Competitive analysis: Retailer density and saturation
   - Market segmentation: License types, status classifications
   - Opportunity scoring: Growth potential and competition levels

### Technical Architecture

```
Raw Data → Data Cleaning → Geocoding → PostgreSQL → Analysis Views → Tableau Dashboards
```

**Data Pipeline Components:**
- **Python Scripts**: Data cleaning, address parsing, geocoding
- **PostgreSQL Database**: Data storage, SQL views, calculated metrics
- **Tableau**: Business intelligence visualization and interactivity

---

## Technical Implementation

### Data Processing & Validation

**Challenge:** OLCC data contained inconsistent address formats, missing city names, and unstructured location information.

**Solution:** Developed robust Python-based data cleaning pipeline:
- Address parsing with regex pattern matching
- City validation against comprehensive Oregon cities database (100+ cities)
- Fallback mechanisms for edge cases and missing data
- Data quality validation rules (ZIP codes, state abbreviations, etc.)

**Results:**
- 100% address parsing accuracy
- Zero records with missing or invalid city names
- Consistent data format across all records
- Eliminated all data quality issues

### Geocoding Implementation

**Challenge:** Needed precise geographic coordinates for mapping and spatial analysis.

**Solution:** Implemented rate-limited geocoding using Python geopy library:
- Used Nominatim API for address-to-coordinate conversion
- Implemented fallback geocoding for failed addresses
- Added rate limiting to respect API usage limits
- Achieved 100% geocoding success rate

**Results:**
- All 761 retailers successfully geocoded
- Average accuracy: street-level precision
- Enabled advanced spatial analysis and mapping
- Foundation for geographic intelligence

### Database Design

**Challenge:** Create scalable data model supporting complex market analysis.

**Solution:** Designed PostgreSQL database with layered architecture:

**Raw Layer (`raw.olcc_retailers`)**
- Complete OLCC retailer data with geocoding
- Primary key on license number
- Indexes on city, county, status, license type
- Loaded timestamp for data freshness tracking

**Mart Layer (`mart.vw_olcc_retailers`)**
- Cleaned, analysis-ready data
- Computed fields (full_address, is_active, license_category)
- Business-friendly column names
- Optimized for Tableau consumption

**Intelligence Layer (`mart.vw_market_intelligence`)**
- Advanced market analysis metrics
- Geographic clustering and regional classification
- Competition scoring and opportunity assessment
- Distance calculations and spatial metrics

**Summary Views**
- `mart.vw_county_market_summary`: County-level aggregations
- `mart.vw_city_market_summary`: City-level aggregations
- Pre-calculated metrics for dashboard performance

---

## Business Intelligence Solution

### Dashboard 1: Oregon Cannabis Market Intelligence Dashboard

**Purpose:** Comprehensive market overview for strategic decision-making

**Key Features:**
- Geographic map with retailer locations and density heat maps
- Market competition analysis by county and city
- License type distribution and market segmentation
- Executive KPIs for quick market assessment

**Business Value:**
- Immediate understanding of market landscape
- Identification of high-opportunity regions
- Competitive intelligence for strategic planning
- Data-driven market entry decisions

### Dashboard 2: Territory Planning & Sales Optimization Dashboard

**Purpose:** Enable strategic territory planning and sales optimization

**Key Features:**
- Territory boundary optimization based on retailer clusters
- Drive-time analysis from major population centers
- Sales opportunity scoring by geographic region
- Competitive gap analysis and market penetration assessment

**Business Value:**
- Optimized territory boundaries for maximum coverage
- Data-driven sales resource allocation
- Identification of underserved markets
- Competitive advantage through superior territory planning

### Dashboard 3: Market Trends & Forecasting Dashboard

**Purpose:** Analyze historical trends and forecast future market expansion

**Key Features:**
- Historical license issuance trends and patterns
- Seasonal analysis and growth velocity metrics
- Predictive modeling for market expansion
- Regional growth comparison and forecasting

**Business Value:**
- Strategic planning based on market trends
- Investment timing and resource allocation
- Competitive positioning in growing markets
- Risk assessment through trend analysis

---

## Skills Demonstrated

### Technical Skills
- **Data Engineering**: End-to-end data pipeline development
- **SQL Development**: Complex views, calculated fields, aggregations
- **Python Programming**: Data cleaning, geocoding, automation
- **Database Design**: Schema design, indexing, performance optimization
- **Geographic Analysis**: Spatial calculations, clustering, mapping
- **Business Intelligence**: Dashboard design, KPI development, data storytelling

### Business Skills
- **Problem Solving**: Translated business needs into technical solutions
- **Data Analysis**: Derived actionable insights from complex datasets
- **Strategic Thinking**: Designed solutions supporting business strategy
- **Communication**: Created clear documentation and specifications
- **Stakeholder Management**: Addressed multiple business requirements
- **Project Management**: Delivered comprehensive solution on time

### Analytical Skills
- **Data Integration**: Combined disparate data sources effectively
- **Quality Assurance**: Implemented rigorous data validation
- **Metric Development**: Created meaningful business metrics
- **Pattern Recognition**: Identified market trends and opportunities
- **Forecasting**: Developed predictive models for market expansion
- **Competitive Analysis**: Assessed market dynamics and competition

---

## Business Impact

### Quantitative Results
- **Data Coverage**: 761 retailers across 30 counties, 115 cities
- **Data Quality**: 100% address parsing and geocoding accuracy
- **Market Intelligence**: Comprehensive competitive analysis
- **Geographic Coverage**: Statewide market visibility

### Qualitative Benefits
- **Strategic Planning**: Data-driven territory and market planning
- **Competitive Advantage**: Superior market intelligence
- **Risk Reduction**: Informed decision-making with data
- **Operational Efficiency**: Optimized resource allocation
- **Market Opportunity**: Identification of growth opportunities

### Use Cases
1. **Market Entry Analysis**: Evaluate new market opportunities
2. **Territory Optimization**: Design optimal sales territories
3. **Competitive Intelligence**: Monitor competitive landscape
4. **Strategic Planning**: Support long-term business strategy
5. **Sales Operations**: Enable data-driven sales decisions

---

## Technical Documentation

### Data Dictionary

**Core Tables:**
- `raw.olcc_retailers`: Raw OLCC data with geocoding
- `mart.vw_olcc_retailers`: Cleaned analysis data
- `mart.vw_market_intelligence`: Advanced market metrics
- `mart.vw_county_market_summary`: County-level aggregations
- `mart.vw_city_market_summary`: City-level aggregations

**Key Metrics:**
- `active_retailers_in_county`: Count of active retailers by county
- `market_competition_level`: Competition classification (High/Medium/Low)
- `geographic_region`: Regional clustering (Portland Metro, Willamette Valley, etc.)
- `distance_from_portland_miles`: Distance calculation for spatial analysis
- `growth_potential`: Opportunity scoring for strategic planning

### Scripts and Automation

**Data Processing:**
- `clean_olcc_retail.py`: Address parsing and data cleaning
- `geocode_olcc_retailers.py`: Geocoding automation
- `create_olcc_retailers_table.sql`: Database table creation
- `load_olcc_retailers.sql`: Data loading automation
- `update_olcc_retailers_geocoded.sql`: Geocoded data update

**Analysis Views:**
- `create_olcc_retailers_mart_view.sql`: Mart layer views
- `create_market_intelligence_view.sql`: Intelligence layer views

**Documentation:**
- `tableau_dashboard_specifications.md`: Dashboard design specifications
- `business_analyst_portfolio.md`: This portfolio documentation

---

## Presentation Strategy

### Portfolio Narrative

**Problem:** Oregon cannabis market lacked actionable intelligence for strategic planning

**Solution:** Built comprehensive market intelligence platform integrating OLCC data with geographic analysis

**Impact:** Enabled data-driven territory planning, market expansion, and competitive intelligence

**Skills Demonstrated:** Data engineering, SQL development, geographic analysis, business intelligence, strategic thinking

### Interview Talking Points

**Technical Depth:**
- "I built an end-to-end data pipeline from raw OLCC data to actionable market intelligence"
- "I implemented geocoding for 761 locations with 100% accuracy using Python and APIs"
- "I designed a layered database architecture with raw, mart, and intelligence layers"
- "I created complex SQL views with calculated metrics for market analysis"

**Business Value:**
- "The solution enables data-driven territory planning and market expansion decisions"
- "I translated business requirements into technical solutions that deliver strategic value"
- "I designed dashboards that answer specific business questions for decision-makers"
- "The platform provides competitive intelligence and opportunity assessment"

**Problem Solving:**
- "I solved data quality issues through robust parsing and validation"
- "I addressed scalability through proper database design and indexing"
- "I implemented fallback mechanisms for edge cases and missing data"
- "I balanced technical complexity with business usability"

### Demonstration Plan

1. **Data Pipeline Walkthrough** (5 minutes)
   - Show raw data quality issues
   - Demonstrate data cleaning process
   - Explain geocoding implementation
   - Highlight data validation results

2. **Database Architecture** (5 minutes)
   - Explain layered design approach
   - Show SQL views and calculated metrics
   - Demonstrate query performance
   - Discuss scalability considerations

3. **Dashboard Demonstration** (10 minutes)
   - Market Intelligence Dashboard
   - Territory Planning Dashboard
   - Market Trends Dashboard
   - Interactive features and insights

4. **Business Impact Discussion** (5 minutes)
   - Quantitative results achieved
   - Qualitative benefits delivered
   - Use cases and applications
   - Future enhancement opportunities

---

## Future Enhancements

### Planned Improvements
- **Population Data Integration**: Add demographic data for market sizing
- **Sales Data Integration**: Connect with actual sales data for opportunity sizing
- **Advanced Analytics**: Machine learning for predictive modeling
- **Real-time Updates**: Automated data refresh and monitoring
- **Mobile Optimization**: Mobile-friendly dashboard access

### Scalability Considerations
- **Multi-State Expansion**: Extend to other states with similar markets
- **Additional Data Sources**: Integrate complementary market data
- **Advanced Visualizations**: 3D mapping, interactive territory planning
- **API Development**: Enable programmatic access to market intelligence

---

## Conclusion

This Oregon Cannabis Market Intelligence Platform demonstrates comprehensive business analyst skills through end-to-end development of a data-driven solution. The project showcases technical expertise in data engineering, SQL development, and geographic analysis, combined with business acumen in strategic planning, competitive intelligence, and market analysis.

The solution delivers tangible business value through actionable market intelligence that supports data-driven decision-making. The comprehensive documentation and professional presentation make this an ideal portfolio piece for business analyst roles, demonstrating both technical depth and business impact.

---

## Contact Information

**Project Repository:** Available upon request  
**Sample Dashboards:** Available for demonstration  
**Technical Documentation:** Complete documentation provided  
**References:** Available upon request

---

*This portfolio project demonstrates the skills and capabilities required for senior business analyst roles, with emphasis on data engineering, business intelligence, and strategic analysis in the CPG industry.*
