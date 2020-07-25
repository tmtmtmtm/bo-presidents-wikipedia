module.exports = (id, startdate, enddate, replaces, replacedby, ordinal) => {
  const qualifiers = { }

  // Seems like there should be a better way of filtering these...
  if (startdate && startdate != "''")   qualifiers['P580']  = startdate
  if (enddate && enddate != "''")       qualifiers['P582']  = enddate
  if (replaces && replaces != "''")     qualifiers['P1365'] = replaces
  if (replacedby && replacedby != "''") qualifiers['P1366'] = replacedby
  if (ordinal && ordinal != "''")       qualifiers['P1545'] = ordinal

  if (startdate && enddate && startdate != "''" && enddate != "''" &&
    (startdate > enddate)) throw new Error(`Invalid dates: ${startdate} / ${enddate}`)

  return {
    id,
    claims: {
      P39: {
        value: 'Q373548',
        qualifiers: qualifiers,
        references: {
          P143: 'Q8447', // frwiki
          P4656: 'https://fr.wikipedia.org/wiki/Liste_des_pr%C3%A9sidents_de_la_Bolivie'
        },
      }
    }
  }
}
