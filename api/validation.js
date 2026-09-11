const pokemonTypes = new Set([
  'Normal', 'Grass', 'Fire', 'Water', 'Electric', 'Psychic', 'Ice', 'Dragon',
  'Dark', 'Fairy', 'Fighting', 'Flying', 'Poison', 'Ground', 'Rock', 'Bug',
  'Ghost', 'Steel'
])

function validatePokemonPayload(body) {
  const name = String(body.name ?? '').trim()
  if (!name) return 'Pokemon Name is required'

  const avatar = String(body.avatar ?? '').trim()
  if (avatar && !/^https?:\/\/\S+$/i.test(avatar)) return 'Enter a valid Avatar URL'

  const type1 = String(body.type1 ?? '').trim()
  if (!type1) return 'Type 1 is required'
  if (!pokemonTypes.has(type1)) return 'Type 1 is invalid'

  const type2Value = String(body.type2 ?? '').trim()
  const type2 = type2Value && type2Value.toLowerCase() !== 'none'
    ? type2Value
    : 'None'
  if (type2 !== 'None' && !pokemonTypes.has(type2)) return 'Type 2 is invalid'

  const num = String(body.num ?? '').trim()
  if (!/^\d{3}$/.test(num)) return 'Number must be exactly 3 digits'

  const statNames = ['total', 'hp', 'atk', 'def', 'spatk', 'spdef', 'spd']
  const values = {}
  for (const field of statNames) {
    const value = String(body[field] ?? '').trim()
    if (!/^\d+$/.test(value)) return `${field} must be a whole number`
    values[field] = Number(value)
  }

  const statsTotal = values.hp + values.atk + values.def + values.spatk + values.spdef + values.spd
  if (statsTotal !== values.total) {
    return statsTotal > values.total
      ? `Stats exceed Total by ${statsTotal - values.total}`
      : `Stats are below Total by ${values.total - statsTotal}`
  }

  return null
}

module.exports = { validatePokemonPayload }
