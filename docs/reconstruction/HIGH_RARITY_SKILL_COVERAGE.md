# High-rarity skill coverage

The target APK contains 3,730 SkillInfo records. 3,235 have a usable stored English description. Of 420 top-grade (`airpower=5`) records, 360 have a stored English description. The audit follows the referenced SkillTagInfo action IDs through SkillTemplateInfo into 82 present Lua action classes. Localized text and action-class presence are measured separately from battle effects.

The 60 untranslated top-grade records are five levels each of skill families 595–602 and 604–607. At the first level their English name keys are absent too. The selected live player's currently owned skills did not include a top-grade record in this set. These families need a controlled fixture to confirm which tag descriptions render and which require more source data.

The Pet skill view now falls back to the APK's own dynamic tag descriptions when the main localization key is missing or empty. The fallback uses client-calculated template parameters. Empty descriptions are ignored without suppressing valid tags. The APK's battle rules, numeric grades and action formulas remain authoritative for this patch. No new effects or mismatched descriptions were authored.

The update builds, signs and launches with the target catalog hashes. Android battle acceptance for high-rarity direct damage, healing, shields, buffs, debuffs, passive effects and Rage still requires controlled runs that exercise each corresponding effect with the expected targets and persisted skill slots. New effect categories Android-verified in this run: zero.
