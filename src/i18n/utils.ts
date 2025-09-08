import { ui, defaultLang } from './ui'

export function getLangFromUrl(url: URL) {
  const [, lang] = url.pathname.split('/')
  if (lang in ui) return lang as keyof typeof ui
  return defaultLang
}

export function useTranslations(lang: keyof typeof ui) {
  return function t(key: keyof typeof ui[typeof defaultLang]) {
    return ui[lang][key] || ui[defaultLang][key]
  }
}

export function getLocaleFromUrl(url: URL): string {
  const pathname = url.pathname
  const segments = pathname.split('/')
  
  // Check if the first segment is a locale
  if (segments.length > 1 && segments[1] in ui) {
    return segments[1]
  }
  
  return defaultLang
}

export function localizeUrl(url: string, locale: string): string {
  if (locale === defaultLang) {
    return url
  }
  return `/${locale}${url}`
}

export function removeLocaleFromUrl(url: string): string {
  const segments = url.split('/')
  if (segments.length > 1 && segments[1] in ui) {
    return '/' + segments.slice(2).join('/')
  }
  return url
}