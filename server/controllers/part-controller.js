const ApiError = require('../error/api-error')

const {Part, PartType} = require('../database/models')
const sequelize = require("../database/database");


class PartController
{
    async addNew(req, res, next)
    {
        try
        {
            const d = new Date()
            const dd = String(d.getDate()).padStart(2, '0')
            const mm = String(d.getMonth() + 1).padStart(2, '0')
            const yy = String(d.getFullYear()).slice(-2)

            const {batch_number, warehouse_id, part_type_id} = req.body
            if (!batch_number || !warehouse_id || !part_type_id)
            {
                return next(new ApiError.badRequest("Incorrect request data"))
            }

            const type = await PartType.findOne({where: {part_type_id}})
            if (!type)
            {
                return next(new ApiError.badRequest("Part type not found"))
            }

            const [[{queue}]] = await sequelize.query("SELECT nextval('\"Parts_part_id_seq\"') as queue;")
            const part = await Part.create({
                serial_number: `${type.dataValues.type_code.toUpperCase()}${dd}${mm}${yy}H${queue}`,
                batch_number: batch_number,
                manufacture_date: new Date(),
                warehouse_id: warehouse_id,
                part_type_id: part_type_id
            })
            return res.json(part)
        }
        catch(e)
        {
            return next(new ApiError.internal('Request error: ' + e.message))
        }
    }

    async findAll(req, res, next)
    {
        try
        {
            const parts = await Part.findAndCountAll()
            return res.json(parts)
        }
        catch(e)
        {
            return next(new ApiError.internal('Request error: ' + e.message))
        }
    }

    async findOne(req, res, next)
    {
        try
        {
            const {id} = req.params
            const part = await Part.findOne({where: {part_id: id}})
            if(part)
            {
                return next(part.dataValues)
            }
            else
            {
                return next(new ApiError.notFound('Part not found'))
            }
        }
        catch(e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async remove(req, res, next)
    {
        try
        {
            const {id} = req.body
            if(isNaN(id))
            {
                return next(new ApiError.badRequest("Incorrect request data"))
            }
            await Part.destroy({where: {part_id: id.toString()}})
            return res.json({message: 'Ok'})
        }
        catch(e)
        {
            return next(new ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new PartController()
