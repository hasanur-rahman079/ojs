{**
 * templates/frontend/components/registrationFormContexts.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme registration form contexts component matching Figma design
 *}

{* Only show context-specific options if we have contexts available and not in journal context *}
{if !$currentContext && $contexts && $contexts|@count}
	<div class="form-group">
		<label for="journalSelect" class="form-label">
			Which journal would you like to login with?
		</label>
		<select 
			id="journalSelect" 
			name="journalSelect" 
			class="form-select"
		>
			<option value="">Select a journal</option>
			{foreach from=$contexts item=context}
				<option value="{$context->getId()}">{$context->getLocalizedName()|escape}</option>
			{/foreach}
		</select>
		<input type="hidden" name="readerGroup" id="readerGroupField" value="">
	</div>

	<script>
	document.getElementById('journalSelect').addEventListener('change', function() {
		// Store selected journal for registration
		document.getElementById('readerGroupField').value = this.value;
	});
	</script>
{/if}