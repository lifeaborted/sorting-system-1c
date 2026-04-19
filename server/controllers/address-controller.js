const ApiError = require('../error/api-error')
const {Address} = require('../database/models')
const e = require("express");

class AddressController
{
    async addNew(req, res, next)
    {
        try
        {
            const {country, region, city, street, building, postal_code} = req.body
            if (!country || !region || !city || !street || !building || !postal_code)
            {
                return next(ApiError.badRequest("Incorrect request data"))
            }

            const [address] = await Address.findOrCreate({
                where: {country, region, city, street, building, postal_code},
                defaults: {country, region, city, street, building, postal_code}
            })

            return res.json(address)
        }
        catch (e)
        {
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findAll(req, res, next)
    {
        try
        {
            const addresses = await Address.findAndCountAll()
            return res.json(addresses)
        }
        catch (e)
        {
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findOne(req, res, next)
    {
        try
        {
            const {id} = req.params
            const address = await Address.findOne({where: {address_id: id}})
            if(address)
            {
                return res.json(address.dataValues)
            }
            else
            {
                return next(ApiError.notFound('Address not found'))
            }
        }
        catch (e)
        {
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async remove(req, res, next)
    {
        try
        {
            const {id} = req.body
            await Address.destroy({where: {address_id: id.toString()}})
            return res.json({message: 'Ok'})
        }
        catch (e)
        {
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new AddressController()