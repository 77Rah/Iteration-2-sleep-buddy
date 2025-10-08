// src/services/playgroundsApi.js

const CKAN_BASE = 'https://discover.data.vic.gov.au/api/3/action/datastore_search'

// Use .env if present; otherwise the provided resource_id.
const DEFAULT_RESOURCE_ID =
  import.meta?.env?.VITE_DVIC_PLAYGROUNDS_RESOURCE_ID || 'e8dc7da3-c352-4b10-b4a7-ff202b7368d9'

/**
 * Query DataVic CKAN datastore.
 * @param {Object} opts
 * @param {string} opts.resourceId - CKAN resource_id
 * @param {string} [opts.q] - Full text query (e.g., suburb name)
 * @param {number} [opts.limit] - Number of rows
 * @param {number} [opts.offset] - Offset for pagination
 * @param {Object} [opts.filters] - CKAN filters object (optional)
 */
export async function searchCKAN({
  resourceId = DEFAULT_RESOURCE_ID,
  q = '',
  limit = 50,
  offset = 0,
  filters = null,
} = {}) {
  const params = new URLSearchParams({
    resource_id: resourceId,
    limit: String(limit),
    offset: String(offset),
  })
  if (q) params.set('q', q)
  if (filters) params.set('filters', JSON.stringify(filters))

  const url = `${CKAN_BASE}?${params}`
  const res = await fetch(url)
  if (!res.ok) throw new Error(`CKAN request failed: ${res.status}`)
  const json = await res.json()
  if (!json.success) throw new Error('CKAN response not successful')
  return {
    records: json.result?.records ?? [],
    total: json.result?.total ?? 0,
    fields: json.result?.fields ?? [],
  }
}

/** Minimal CSV parser (RFC-4180-ish) supporting quoted fields and commas/newlines in quotes */
function parseCSV(text) {
  const rows = []
  let row = []
  let field = ''
  let i = 0
  let inQuotes = false

  while (i < text.length) {
    const char = text[i]

    if (inQuotes) {
      if (char === '"') {
        const next = text[i + 1]
        if (next === '"') {
          field += '"'
          i += 2
          continue
        } // escaped quote
        inQuotes = false
        i++
        continue
      }
      field += char
      i++
      continue
    }

    if (char === '"') {
      inQuotes = true
      i++
      continue
    }
    if (char === ',') {
      row.push(field)
      field = ''
      i++
      continue
    }
    if (char === '\r') {
      i++
      continue
    }
    if (char === '\n') {
      row.push(field)
      rows.push(row)
      row = []
      field = ''
      i++
      continue
    }

    field += char
    i++
  }
  // last field
  row.push(field)
  rows.push(row)
  return rows
}

/**
 * Load local CSV at /data/playgrounds.csv (put your file in /public/data/).
 * Returns {records, total, fields}
 */
export async function loadLocalCSV(url = '/data/playgrounds.csv', limit = 5000) {
  const text = await fetch(url).then((r) => {
    if (!r.ok) throw new Error(`CSV fetch failed: ${r.status}`)
    return r.text()
  })

  const rows = parseCSV(text).filter((r) => r.length && r.some((c) => c !== ''))
  if (rows.length === 0) return { records: [], total: 0, fields: [] }

  const headers = rows[0].map((h) => h.trim())
  const dataRows = rows.slice(1, 1 + limit)

  const records = dataRows.map((cells) => {
    const obj = {}
    headers.forEach((h, i) => {
      obj[h] = (cells[i] ?? '').trim()
    })
    return obj
  })

  return {
    records,
    total: records.length,
    fields: headers.map((n) => ({ id: n })),
  }
}

/** Try to normalize lat/lon from a record with many possible field names/shapes. */
export function extractCoords(rec) {
  // Common direct field name pairs
  const pairs = [
    ['lat', 'lon'],
    ['latitude', 'longitude'],
    ['y', 'x'],
    ['LAT', 'LON'],
    ['Lat', 'Long'],
    ['LATITUDE', 'LONGITUDE'],
    ['lat_dd', 'lon_dd'],
    ['lat_wgs84', 'lon_wgs84'],
    ['Latitude', 'Longitude'],
    ['Y', 'X'], // sometimes reversed semantics, check below if needed
  ]

  for (const [la, lo] of pairs) {
    const lat = Number(rec[la])
    const lon = Number(rec[lo])
    if (Number.isFinite(lat) && Number.isFinite(lon)) return { lat, lon }
  }

  // CKAN geo_point_2d might be an object {lat, lon} or a string "lat, lon"
  const gp = rec.geo_point_2d || rec['geo_point_2d']
  if (gp) {
    if (typeof gp === 'object' && gp.lat != null && gp.lon != null) {
      const lat = Number(gp.lat),
        lon = Number(gp.lon)
      if (Number.isFinite(lat) && Number.isFinite(lon)) return { lat, lon }
    }
    if (typeof gp === 'string') {
      const m = gp.match(/(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)/)
      if (m) {
        const lat = Number(m[1]),
          lon = Number(m[2])
        if (Number.isFinite(lat) && Number.isFinite(lon)) return { lat, lon }
      }
    }
  }

  // WKT POINT "POINT (144.9631 -37.8136)" → note: WKT is "lon lat"
  const wkt = rec.location || rec.geom || rec.geometry || rec.point || rec.wkt
  if (typeof wkt === 'string') {
    const m = wkt.match(/POINT\s*\(\s*(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s*\)/i)
    if (m) {
      const lon = Number(m[1])
      const lat = Number(m[2])
      if (Number.isFinite(lat) && Number.isFinite(lon)) return { lat, lon }
    }
  }

  // Some datasets encode geometry as GeoJSON
  if (rec.geometry && typeof rec.geometry === 'object' && Array.isArray(rec.geometry.coordinates)) {
    const [lon, lat] = rec.geometry.coordinates
    if (Number.isFinite(lat) && Number.isFinite(lon)) return { lat, lon }
  }

  return null
}

/** Pick a friendly title for list & popup. Adjust if your dataset has known field names. */
export function recordTitle(r) {
  return (
    r.name ||
    r.Name ||
    r.SITE_NAME ||
    r.site_name ||
    r.park_name ||
    r.PlaygroundName ||
    r.title ||
    r.TITLE ||
    r.Facility ||
    'Playground'
  )
}

/** Subtitle line below the title. */
export function recordSubtitle(r) {
  const parts = [
    r.address || r.Address || r.ADDRESS,
    r.suburb || r.Suburb || r.SUBURB,
    r.municipality || r.council || r.LGA || r.local_government_area,
    r.postcode || r.Postcode || r.POSTCODE,
  ].filter(Boolean)
  return parts.join(' • ')
}
