const ApiError = require('../error/api-error')
const {Warehouse, Address} = require('../database/models')
const e = require("express");

class WarehouseController
{
    async addNew(req, res, next)
    {
        try
        {
            const {name, address_id} = req.body
            if (!name || !address_id)
            {
                return res.json(ApiError.badRequest("Incorrect request data"))
            }

            const [warehouse] = await Warehouse.findOrCreate({
                where: { name, address_id },
                defaults: { name, address_id },
                include: [{ model: Address, as: 'address' }]
            })

            return res.json(warehouse)
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findAll(req, res, next)
    {
        try
        {
            const warehouses = await Warehouse.findAndCountAll({include: [{ model: Address, as: 'address' }]})
            return res.json(warehouses)
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findOne(req, res, next)
    {
        try
        {
            const {id} = req.params
            const warehouse = await Warehouse.findOne({where: {warehouse_id: id}, include: [{ model: Address, as: 'address' }]})
            if(warehouse)
            {
                return res.json(warehouse.dataValues)
            }
            else
            {
                return next(new ApiError.notFound('Warehouse not found'))
            }
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async remove(req, res, next)
    {
        try
        {
            const {id} = req.body
            await Warehouse.destroy({where: {warehouse_id: id.toString()}})
            return res.json({status: 200, message: 'Ok'})
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new WarehouseController()