const ApiError = require('../error/api-error')
const {Address} = require('../database/models')

class AddressController
{
    async addNew(req, res)
    {
        try
        {
            const {country, region, city, street, building, postal_code} = req.body
            if (!country || !region || !city || !street || !building || !postal_code)
            {
                return res.json(ApiError.badRequest("Incorrect request data"))
            }

            const [address] = await Address.findOrCreate({
                where: {country, region, city, street, building, postal_code},
                defaults: {country, region, city, street, building, postal_code}
            })

            return res.json(address)
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findAll(req, res)
    {
        try
        {
            const addresses = await Address.findAndCountAll()
            return res.json(addresses)
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findOne(req, res)
    {
        try
        {
            const {id} = req.params
            const address = await Address.findOne({where: {address_id: id}})
            return res.json(address ? address.dataValues : ApiError.notFound('Address not found'))
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async remove(req, res)
    {
        try
        {
            const {id} = req.body
            await Address.destroy({where: {address_id: id.toString()}})
            return res.json({status: 200, message: 'Ok'})
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new AddressController()