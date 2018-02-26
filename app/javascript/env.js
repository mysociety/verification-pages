const host = process.env.HOST_NAME
const protocol = process.env.FORCE_SSL === '1' ? 'https' : 'http'
const url = host ? protocol + '://' + host : ''

export default { url }
