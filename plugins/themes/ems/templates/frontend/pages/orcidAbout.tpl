{include file="frontend/components/header.tpl" pageTitle="orcid.about.title"}

<div class="page page_orcid_about ems-orcid-about-page">
	<div class="orcid-about-container">
		<div class="orcid-about-content">
			<h1 class="orcid-about-title">
				{translate key="orcid.about.title"}
			</h1>

			<div class="orcid-about-body">
				<div class="orcid-intro-section">
					<div class="orcid-icon-large">
						<svg width="80" height="80" viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
							<rect width="80" height="80" rx="40" fill="#A6CE39"/>
							<g transform="translate(16, 16)">
								<text x="24" y="40" text-anchor="middle" font-family="Arial, sans-serif" font-size="28" font-weight="bold" fill="white">iD</text>
								<circle cx="24" cy="16" r="2.5" fill="white"/>
							</g>
						</svg>
					</div>
					<div class="orcid-intro-text">
						<p class="orcid-description">
							{translate key="orcid.about.orcidExplanation"}
						</p>
					</div>
				</div>

				<div class="orcid-sections">
					<div class="orcid-section">
						<div class="orcid-section-header">
							<div class="orcid-section-icon">
								<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" stroke="#019863"/>
								</svg>
							</div>
							<h3 class="orcid-section-title">
								{translate key="orcid.about.howAndWhy.title"}
							</h3>
						</div>
						<div class="orcid-section-content">
							{if $isMemberApi}
								<p>{translate key="orcid.about.howAndWhyMemberAPI"}</p>
							{else}
								<p>{translate key="orcid.about.howAndWhyPublicAPI"}</p>
							{/if}
						</div>
					</div>

					<div class="orcid-section">
						<div class="orcid-section-header">
							<div class="orcid-section-icon">
								<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" stroke="#019863"/>
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" stroke="#019863"/>
								</svg>
							</div>
							<h3 class="orcid-section-title">
								{translate key="orcid.about.display.title"}
							</h3>
						</div>
						<div class="orcid-section-content">
							<p>{translate key="orcid.about.display"}</p>
						</div>
					</div>
				</div>

				<div class="orcid-benefits">
					<h3 class="benefits-title">Benefits of ORCID</h3>
					<div class="benefits-grid">
						<div class="benefit-card">
							<div class="benefit-icon">
								<svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke="#019863"/>
								</svg>
							</div>
							<h4>Unique Identification</h4>
							<p>Distinguish yourself from other researchers with the same or similar names</p>
						</div>
						<div class="benefit-card">
							<div class="benefit-icon">
								<svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" stroke="#019863"/>
								</svg>
							</div>
							<h4>Easy Connections</h4>
							<p>Link your ORCID iD to your publications, grants, and affiliations</p>
						</div>
						<div class="benefit-card">
							<div class="benefit-icon">
								<svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" stroke="#019863"/>
								</svg>
							</div>
							<h4>Streamlined Submissions</h4>
							<p>Automatically populate your profile information when submitting manuscripts</p>
						</div>
					</div>
				</div>

				<div class="orcid-cta">
					<div class="cta-content">
						<h3>Ready to Get Started?</h3>
						<p>Create your free ORCID iD today and enhance your research profile</p>
						<div class="cta-buttons">
							<a href="https://orcid.org/register" target="_blank" class="btn btn-primary">
								<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
									<rect width="20" height="20" rx="10" fill="#A6CE39"/>
									<g transform="translate(3, 3)">
										<text x="7" y="11" text-anchor="middle" font-family="Arial, sans-serif" font-size="10" font-weight="bold" fill="white">iD</text>
										<circle cx="7" cy="4.5" r="0.7" fill="white"/>
									</g>
								</svg>
								Create ORCID iD
							</a>
							<a href="https://orcid.org" target="_blank" class="btn btn-secondary">
								Learn More
							</a>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
