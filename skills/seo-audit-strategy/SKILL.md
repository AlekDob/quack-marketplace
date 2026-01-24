---
name: seo-audit-strategy
description: Comprehensive SEO audit and positioning strategy skill. Analyzes websites for technical SEO, content optimization, keyword strategy, and competitive positioning. Use when user needs SEO improvements, ranking analysis, or content strategy.
license: MIT
---

This skill provides comprehensive SEO auditing and strategic positioning guidance for websites and web applications.

## Core Capabilities

### 1. Technical SEO Audit

Analyze and optimize technical foundation:

**Page Structure**
- HTML semantic structure (headings hierarchy, landmarks)
- Meta tags (title, description, OG, Twitter cards)
- Canonical URLs and URL structure
- Schema.org structured data (JSON-LD)
- XML sitemap and robots.txt

**Performance**
- Core Web Vitals (LCP, FID, CLS)
- Page load speed and optimization
- Image optimization (format, lazy loading, dimensions)
- JavaScript/CSS optimization
- Mobile responsiveness and viewport

**Indexability**
- Crawlability issues
- Internal linking structure
- Broken links and redirects
- Duplicate content
- Pagination and infinite scroll handling

**Security & Accessibility**
- HTTPS implementation
- WCAG compliance
- Alt text for images
- ARIA labels where needed

### 2. Content Analysis

Evaluate and optimize content:

**Keyword Strategy**
- Primary keyword identification
- Secondary/LSI keywords
- Keyword density and placement
- Search intent alignment (informational, transactional, navigational)
- Long-tail keyword opportunities

**Content Quality**
- Originality and uniqueness
- Depth and comprehensiveness
- Readability (Flesch score, sentence length)
- Content freshness and update frequency
- User engagement signals

**On-Page Optimization**
- Title tag optimization (50-60 chars, keyword placement)
- Meta description (150-160 chars, call-to-action)
- H1-H6 hierarchy and keyword usage
- Image alt text and file names
- Internal linking strategy
- External linking (authority, relevance)

### 3. Competitive Analysis

Understand the competitive landscape:

**Competitor Research**
- Identify top-ranking competitors for target keywords
- Analyze their content strategies
- Backlink profile comparison
- Domain authority and page authority
- Content gaps and opportunities

**SERP Analysis**
- Featured snippets opportunities
- "People Also Ask" questions
- Related searches
- SERP features (videos, images, local pack)

### 4. Keyword Research & Strategy

Develop data-driven keyword strategy:

**Keyword Discovery**
- Search volume analysis
- Keyword difficulty assessment
- Cost-per-click (CPC) data
- Seasonal trends
- Question-based keywords

**Keyword Prioritization**
- Intent alignment with business goals
- Competition vs. opportunity matrix
- Quick wins vs. long-term plays
- Local vs. global targeting

**Content Mapping**
- Keyword to page mapping
- Content cluster strategy
- Topic authority building
- Pillar page identification

### 5. Local SEO (when applicable)

Optimize for local search:

**Google Business Profile**
- NAP consistency (Name, Address, Phone)
- Categories and attributes
- Reviews management
- Posts and updates

**Local Citations**
- Directory submissions
- Schema markup (LocalBusiness)
- Local keywords integration

### 6. International SEO (when applicable)

Optimize for multiple languages/regions:

**Hreflang Implementation**
- Correct hreflang tags
- Language and region targeting
- URL structure (subdomain, subdirectory, ccTLD)

**Content Localization**
- Cultural adaptation
- Local search trends
- Regional keyword variations

## Audit Workflow

When conducting an SEO audit, follow this systematic approach:

### Phase 1: Discovery
1. Understand business goals and target audience
2. Identify current traffic sources and performance
3. Define target keywords and search intent
4. Analyze current SERP positions

### Phase 2: Technical Audit
1. Crawl website for technical issues
2. Check indexation status
3. Analyze Core Web Vitals
4. Review mobile usability
5. Assess site architecture and navigation

### Phase 3: Content Audit
1. Inventory existing content
2. Analyze keyword targeting
3. Evaluate content quality and depth
4. Identify thin or duplicate content
5. Map content to user journey

### Phase 4: Competitive Analysis
1. Identify top 5-10 competitors
2. Analyze their content strategy
3. Review backlink profiles
4. Identify content gaps
5. Find link building opportunities

### Phase 5: Recommendations
1. Prioritize issues by impact and effort
2. Create quick wins list
3. Develop long-term strategy
4. Provide implementation roadmap
5. Define KPIs and measurement plan

## SEO Best Practices

### Title Tags
```html
<!-- ✅ Good -->
<title>Keyword | Brand Name - Value Proposition (50-60 chars)</title>

<!-- ❌ Bad -->
<title>Home | Welcome to Our Website</title>
```

### Meta Descriptions
```html
<!-- ✅ Good -->
<meta name="description" content="Compelling description with primary keyword and call-to-action. 150-160 characters that entice clicks from search results.">

<!-- ❌ Bad -->
<meta name="description" content="Welcome to our site.">
```

### Heading Structure
```html
<!-- ✅ Good -->
<h1>Primary Keyword - Main Topic</h1>
<h2>Secondary Keyword Subtopic</h2>
<h3>Supporting Detail</h3>

<!-- ❌ Bad -->
<h1>Welcome</h1>
<h3>About Us</h3>
<h2>Services</h2>
```

### Structured Data (JSON-LD)
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Course",
  "name": "Course Name",
  "description": "Course description",
  "provider": {
    "@type": "Organization",
    "name": "Provider Name"
  }
}
</script>
```

### Image Optimization
```html
<!-- ✅ Good -->
<img
  src="keyword-descriptive-name.webp"
  alt="Descriptive alt text with keyword"
  width="800"
  height="600"
  loading="lazy"
>

<!-- ❌ Bad -->
<img src="img123.jpg" alt="image">
```

## Italian Market Specifics

### Language Considerations
- Use proper Italian grammar and spelling
- Avoid direct translations from English
- Use Italian-specific keywords and phrases
- Consider regional variations (Milan vs. Rome vs. Sicily)

### Search Behavior
- Italian users prefer longer, more descriptive queries
- Strong preference for local businesses
- Mobile-first behavior (70%+ mobile searches)
- Voice search growing rapidly

### Top Ranking Factors (Italy)
1. Content quality and depth (most important)
2. Mobile optimization (critical)
3. Local signals (especially for services)
4. Domain authority
5. Page speed
6. Social signals (more important than US market)

### Italian SERPs Features
- Featured snippets less common than US
- "People Also Ask" available
- Local pack very prominent
- Google Discover significant traffic source

## Tools and Resources

### Free Tools
- Google Search Console (indexation, performance)
- Google Analytics (traffic, behavior)
- Google PageSpeed Insights (Core Web Vitals)
- Google Mobile-Friendly Test
- Schema.org validator
- Screaming Frog (free version, 500 URLs)

### Paid Tools (optional)
- Semrush / Ahrefs (comprehensive analysis)
- Moz Pro (domain authority tracking)
- Ubersuggest (budget-friendly)

### Italian-Specific
- SEOZoom (Italian SEO tool)
- Sistrix (includes Italian market data)
- Google Trends Italia

## Reporting and KPIs

### Key Metrics to Track
- Organic traffic (overall and per-page)
- Keyword rankings (top 10, top 3, featured snippets)
- Click-through rate (CTR) from SERPs
- Bounce rate and time on page
- Conversions from organic traffic
- Indexed pages
- Core Web Vitals scores
- Domain authority growth

### Reporting Frequency
- Quick wins: Weekly tracking
- Technical fixes: Monthly review
- Content strategy: Monthly review
- Competitive analysis: Quarterly
- Full audit: Every 6 months

## Output Format

When providing SEO recommendations, structure as:

1. **Executive Summary**: 3-5 bullet points of critical findings
2. **Technical Issues**: Prioritized list with severity (Critical/High/Medium/Low)
3. **Content Recommendations**: Specific pages and improvements
4. **Keyword Strategy**: Target keywords with difficulty and opportunity scores
5. **Competitive Insights**: What competitors are doing better
6. **Quick Wins**: 5-10 actionable items for immediate impact
7. **Long-Term Strategy**: 3-6 month roadmap
8. **Implementation Guide**: Step-by-step instructions
9. **Success Metrics**: KPIs to track progress

## Remember

- **Context matters**: SEO strategy varies by industry, audience, and goals
- **Think user-first**: Google rewards content that serves user intent
- **Be specific**: Provide actionable recommendations, not generic advice
- **Prioritize**: Focus on high-impact, achievable improvements
- **Measure everything**: Define clear KPIs before implementing changes
- **Stay updated**: SEO best practices evolve; reference latest Google guidelines

When auditing Italian sites, emphasize:
- Mobile optimization (critical in Italian market)
- Local SEO signals (very important for Italian searches)
- Content depth (Italian users expect comprehensive answers)
- Social signals (more influential in Italy than US)
- Language quality (proper Italian, not machine translated)
