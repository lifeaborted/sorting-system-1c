const ApiError = require('../error/api-error')

const {PartType, Address} = require('../database/models')
const e = require("express");


class PartTypeController
{
    async addNew(req, res, next)
    {
        try
        {
            const {name, type_code} = req.body
            if(!name || !type_code)
            {
                return next(ApiError.badRequest("Incorrect request data"))
            }

            const [partType] = await PartType.findOrCreate({
                where: {name, type_code},
                defaults: {name, type_code}
            })

            return res.json(partType)
        }
        catch(e)
        {
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findAll(req, res, next)
    {
        try
        {
            const partTypes = await PartType.findAndCountAll()
            return res.json(partTypes)
        }
        catch(e)
        {
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findOne(req, res, next)
    {
        try
        {
            const {id} = req.params
            const partType = await PartType.findOne({where: {part_type_id: id}})
            if(partType)
            {
                return res.json(partType.dataValues)
            }
            else
            {
                return next(ApiError.notFound('PartType not found'))
            }

        }
        catch(e)
        {
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async remove(req, res, next)
    {
        try
        {
            const {id} = req.body
            if(isNaN(id))
            {
                return next(ApiError.badRequest("Incorrect request data"))
            }
            await PartType.destroy({where: {part_type_id: id.toString()}})
            return res.json({status: 200, message: 'Ok'})
        }
        catch(e)
        {
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new PartTypeController()
