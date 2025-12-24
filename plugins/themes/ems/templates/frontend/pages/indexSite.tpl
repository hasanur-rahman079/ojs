{**
 * templates/frontend/pages/indexSite.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme landing page matching Figma design
 *}

{include file="frontend/components/header.tpl"}

<div class="page_index_site">
<main class="main-content">
	{* Hero Section *}
	<section class="ems-hero">
		<div class="hero-container">
			<div class="hero-background"></div>
			<div class="hero-content">
				<h1 class="hero-title">Modern Peer Review, Simplified.</h1>
				<p class="hero-description">An intuitive and powerful editorial management system for scientific journals.</p>
				<div class="hero-buttons">
					<a href="#demo" class="btn btn-primary btn-hero">Get Started</a>
				</div>
			</div>
		</div>
	</section>

	{* Who We Serve Section *}
	<section class="ems-section who-section">
		<div class="section-container-inner">
			<div class="section-bg">
				<h2 class="section-title">Who We Serve?</h2>
				<div class="feature-grid">
					<div class="feature-card">
						<div class="feature-icon">
							<img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-university.svg" alt="" />
						</div>
						<h3 class="feature-title">University Presses</h3>
						<p class="feature-description">Streamline your entire portfolio of journals with a single, powerful system.</p>
					</div>
					<div class="feature-card">
						<div class="feature-icon">
							<img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-society.svg" alt="" />
						</div>
						<h3 class="feature-title">Academic Societies</h3>
						<p class="feature-description">Enhance collaboration and efficiency for your society's publications.</p>
					</div>
					<div class="feature-card">
						<div class="feature-icon">
							<img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-editor.svg" alt="" />
						</div>
						<h3 class="feature-title">Independent Journal Editors</h3>
						<p class="feature-description">Manage your journal with ease, from submission to publication.</p>
					</div>
				</div>
				
				{* Testimonial *}
				<div class="testimonial-section">
					<div class="testimonial-content">
						<blockquote class="testimonial-quote">
							"ems.pub has transformed how we manage our journal. The intuitive interface and powerful features have saved us countless hours."
						</blockquote>
						<div class="testimonial-attribution">
							<p>Md. Jamal Uddin,</p>
							<p>Editor-in-Chief, Journal of Advanced Biotechnology and Experimental Therapeutics</p>
						</div>
					</div>
				</div>
			</div>
		</div>
	</section>

	{* What ems.pub Does Section *}
	<section class="ems-section workflow-section">
		<div class="section-container-inner">
			<div class="section-bg">
				<h2 class="section-title">What ems.pub Does</h2>
				<div class="workflow-grid">
					<div class="workflow-card">
						<div class="workflow-icon">
							<img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-submission.svg" alt="" />
						</div>
						<div class="workflow-text">Submission</div>
					</div>
					<div class="workflow-card">
						<div class="workflow-icon">
							<img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-peer-review.svg" alt="" />
						</div>
						<div class="workflow-text">Peer Review</div>
					</div>
					<div class="workflow-card">
						<div class="workflow-icon">
							<img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-production.svg" alt="" />
						</div>
						<div class="workflow-text">Production</div>
					</div>
					<div class="workflow-card">
						<div class="workflow-icon">
							<img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-publication.svg" alt="" />
						</div>
						<div class="workflow-text">Publication</div>
					</div>
				</div>
			</div>
		</div>
	</section>

	{* Built for Modern Scholarly Ecosystem Section *}
	<section class="ems-section ecosystem-section">
		<div class="section-container-inner">
			<div class="section-bg">
				<h2 class="section-title">Built for the Modern Scholarly Ecosystem</h2>
				<div class="integration-grid">
					<div class="integration-card">
						<img src="{$baseUrl}/plugins/themes/ems/templates/images/orcid_logo.png" class="integration-logo" alt="ORCID" />
						<div class="integration-text">ORCID Integration</div>
					</div>
					<div class="integration-card">
						<img src="{$baseUrl}/plugins/themes/ems/templates/images/crossref_logo.png" class="integration-logo" alt="CrossRef" />
						<div class="integration-text">CrossRef Support</div>
					</div>
					<div class="integration-card">
						<div class="integration-icon">
							<img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-jats.svg" alt="" />
						</div>
						<div class="integration-text">JATS Compliance</div>
					</div>
				</div>
				<div class="integration-grid">
					<div class="integration-card">
						<div class="integration-icon google">
							<span>G</span>
						</div>
						<div class="integration-text">Google Scholar</div>
					</div>
					<div class="integration-card">
						<img src="{$baseUrl}/plugins/themes/ems/templates/images/pubmed_logo.png" class="integration-logo pubmed" alt="PubMed" />
						<div class="integration-text">Pubmed Support</div>
					</div>
					<div class="integration-card">
						<img src="{$baseUrl}/plugins/themes/ems/templates/images/dublin_core_logo.png" class="integration-logo" alt="Dublin Core" />
						<div class="integration-text">Dublin Core Support</div>
					</div>
				</div>
			</div>
		</div>
	</section>

	{* Transparent, Scalable Pricing Section *}
	<section class="ems-section pricing-section" id="pricing">
		<div class="section-container">
			<div class="pricing-header">
				<h2 class="pricing-main-title">Transparent, Scalable Pricing</h2>
				<p class="pricing-subtitle">Choose a plan that fits your journal's submission volume — pay only for what you need.</p>
			</div>
			<div class="pricing-grid">
				<div class="pricing-card">
					<h3 class="pricing-title">Starter</h3>
					<p class="pricing-for">For Independent Journals</p>
					<div class="pricing-amount">Up to 100</div>
					<div class="pricing-period">submissions/year</div>
					<ul class="pricing-features">
						<li><img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-checkmark.svg" alt="" /> Hosting Included</li>
						<li><img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-checkmark.svg" alt="" /> Support Included</li>
						<li><img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-checkmark.svg" alt="" /> Submission System</li>
					</ul>
				</div>
				<div class="pricing-card popular">
					<div class="popular-badge">Most Popular</div>
					<h3 class="pricing-title">Publisher</h3>
					<p class="pricing-for">For Small Publishers</p>
					<div class="pricing-amount">Up to 500</div>
					<div class="pricing-period">submissions/year</div>
					<ul class="pricing-features">
						<li><img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-checkmark.svg" alt="" /> Manage Multiple Journals</li>
						<li><img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-checkmark.svg" alt="" /> All Starter Features</li>
					</ul>
				</div>
				<div class="pricing-card">
					<h3 class="pricing-title">Enterprise</h3>
					<p class="pricing-for">For Universities & Publishers</p>
					<div class="pricing-amount">Custom</div>
					<div class="pricing-period">volume-based pricing</div>
					<ul class="pricing-features">
						<li><img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-checkmark.svg" alt="" /> Unlimited Journals</li>
						<li><img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-checkmark.svg" alt="" /> Advanced Analytics</li>
						<li><img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-checkmark.svg" alt="" /> Custom Integrations</li>
					</ul>
				</div>
			</div>
		</div>
	</section>


	{* Hosted Journals Section *}
	{if $journals && $journals|@count}
		<section class="ems-section hosted-journals-section" id="journals">
			<div class="journals-wrapper">
				<div class="journals-container">
					{* Page Header *}
					<div class="journals-header">
						<h2 class="journals-title">Journals</h2>
						<p class="journals-description">Browse our collection of prestigious scientific journals. Find the perfect platform for your research and submit your work with ease.</p>
					</div>

					{* Search Bar *}
					<div class="search-container">
						<div class="search-wrapper">
							<div class="search-icon">
								<img src="{$baseUrl}/plugins/themes/ems/templates/images/icon-search.svg" alt="" />
							</div>
							<input 
								type="text" 
								id="journal-search" 
								class="search-input" 
								placeholder="Search for journals by name or keyword"
								onkeyup="filterJournals()"
							>
						</div>
					</div>

					{* Journals Grid *}
					<div class="journals-grid" id="journals-grid">
						{foreach from=$journals item=journal}
							{capture assign="journalUrl"}{url journal=$journal->getPath()}{/capture}
							{assign var="thumb" value=$journal->getLocalizedData('journalThumbnail')}
							{assign var="description" value=$journal->getLocalizedDescription()}
							
							<div class="journal-card" data-journal-name="{$journal->getLocalizedName()|escape|lower}">
								<div class="journal-image-container">
									{if $thumb}
										<img src="{$journalFilesPath}{$journal->getId()}/{$thumb.uploadName|escape:"url"}" alt="{$journal->getLocalizedName()|escape}" class="journal-image" />
									{else}
										<div class="journal-image-placeholder"></div>
									{/if}
								</div>
								<div class="journal-content">
									<h3 class="journal-name">{$journal->getLocalizedName()|escape}</h3>
									<p class="journal-abbrev">{$journal->getLocalizedAcronym()|escape|default:""}</p>
									<p class="journal-desc">{$description|strip_tags|truncate:100}</p>
								</div>
								<div class="journal-actions">
									<a href="{$journalUrl|escape}" class="btn btn-visit">Visit</a>
									<a href="{url journal=$journal->getPath() page="about" op="submissions"}" class="btn btn-submit-article">Submit</a>
								</div>
							</div>
						{/foreach}
					</div>
				</div>
			</div>
		</section>

		<script>
		function filterJournals() {
			const input = document.getElementById('journal-search');
			const filter = input.value.toLowerCase();
			const grid = document.getElementById('journals-grid');
			const cards = grid.getElementsByClassName('journal-card');

			for (let i = 0; i < cards.length; i++) {
				const journalName = cards[i].getAttribute('data-journal-name');
				if (journalName.indexOf(filter) > -1) {
					cards[i].style.display = '';
				} else {
					cards[i].style.display = 'none';
				}
			}
		}
		</script>
	{/if}

	
	{* Ready to Modernize CTA Section *}
	<section class="ems-section cta-section" id="demo">
		<div class="section-container">
			<div class="cta-content">
				<h2 class="cta-title">Ready to Modernize Your Journal?</h2>
				<p class="cta-description">Schedule a live demo to see how ems.pub can streamline your workflow.</p>
				<a href="#book-demo" class="btn btn-primary btn-cta">Book Your Demo Now</a>
			</div>
		</div>
	</section>

</main>
</div> {* Close page_index_site *}

{include file="frontend/components/footer.tpl"}
