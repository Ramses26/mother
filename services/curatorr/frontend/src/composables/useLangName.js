export const LANG_NAMES = {
  ar: 'Arabic', bn: 'Bengali', bg: 'Bulgarian', ca: 'Catalan',
  cs: 'Czech', da: 'Danish', de: 'German', el: 'Greek',
  en: 'English', es: 'Spanish', et: 'Estonian', fa: 'Persian',
  fi: 'Finnish', fr: 'French', he: 'Hebrew', hi: 'Hindi',
  hr: 'Croatian', hu: 'Hungarian', id: 'Indonesian', it: 'Italian',
  ja: 'Japanese', ko: 'Korean', lt: 'Lithuanian', lv: 'Latvian',
  ms: 'Malay', nb: 'Norwegian', nl: 'Dutch', no: 'Norwegian',
  pl: 'Polish', pt: 'Portuguese', ro: 'Romanian', ru: 'Russian',
  sk: 'Slovak', sl: 'Slovenian', sq: 'Albanian', sr: 'Serbian',
  sv: 'Swedish', sw: 'Swahili', th: 'Thai', tl: 'Filipino',
  tr: 'Turkish', uk: 'Ukrainian', vi: 'Vietnamese',
  zh: 'Chinese', cn: 'Chinese',
}

export const langName = (code) => LANG_NAMES[code] || (code ? code.toUpperCase() : '—')
