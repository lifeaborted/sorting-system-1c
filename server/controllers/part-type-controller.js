const ApiError = require('../error/api-error')

const {PartType, Address} = require('../database/models')


class PartTypeController
{
    async addNew(req, res)
    {
        try
        {
            const {name, type_code} = req.body
            if(!name || !type_code)
            {
                return res.json(ApiError.badRequest("Incorrect request data"))
            }

            const [partType] = await PartType.findOrCreate({
                where: {name, type_code},
                defaults: {name, type_code}
            })

            return res.json(partType)
        }
        catch(e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findAll(req, res)
    {
        try
        {
            const partTypes = await PartType.findAndCountAll()
            return res.json(partTypes)
        }
        catch(e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findOne(req, res)
    {
        try
        {
            const {id} = req.params
            const partType = await PartType.findOne({where: {part_type_id: id}})
            return res.json(partType ? partType.dataValues : ApiError.notFound('PartType not found'))
        }
        catch(e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async remove(req, res)
    {
        try
        {
            const {id} = req.body
            if(isNaN(id))
            {
                return res.json(ApiError.badRequest("Incorrect request data"))
            }
            await PartType.destroy({where: {part_type_id: id.toString()}})
            return res.json({status: 200, message: 'Ok'})
        }
        catch(e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new PartTypeController()
