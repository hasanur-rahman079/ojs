{**
* templates/frontend/components/footer.tpl
*
* Copyright (c) 2024-2025
* Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
*
* @brief EMS theme footer component matching Figma design
*}

{* Footer *}
<footer class="ems-footer pkp_structure_foot {if $currentContext}journal-footer{/if}">
	<div class="footer-container">
		{if $currentContext}
			{* Journal Footer with centered logo - uses main site links *}
			<div class="footer-content journal-footer-content">
				<div class="footer-logo">
					<a href="{$baseUrl}">
						<img src="{$baseUrl}/plugins/themes/ems/templates/images/ems_brand_logo_full.png" alt="ems.pub" class="footer-brand-logo">
					</a>
				</div>
				<div class="footer-links-row">
					<a href="{url page="about"}" class="footer-link">About</a>
					<a href="{url page="about" op="contact"}" class="footer-link">Contact</a>
					<a href="{url page="about" op="privacy"}" class="footer-link">Privacy Policy</a>
				</div>
				<div class="footer-bottom">
					<div class="footer-powered">A system by <a href="https://exomeit.com" target="_blank">ExomeIT</a></div>
					<div class="footer-copyright">© 2025 Editorial Management System (ems.pub). All rights reserved.</div>
				</div>
			</div>
		{else}
			{* Site Footer *}
			<div class="footer-content">
				<div class="footer-links-row">
					<!-- <a href="#features" class="footer-link">About</a> -->
					<a href="#contact" class="footer-link">Terms of Service</a>
					<a href="#contact" class="footer-link">Privacy Policy</a>
				</div>

				<div class="footer-bottom">
					<div class="footer-copyright">
						©2025 Editorial Management System (ems.pub). All rights reserved.
					</div>
					<div class="footer-powered">
						A system by <a href="https://exomeit.com" target="_blank">ExomeIT</a>
					</div>
				</div>
			</div>
		{/if}
	</div>
</footer>

</div> {* Close pkp_structure_page *}

{* Close body and html tags *}
</body>

</html>