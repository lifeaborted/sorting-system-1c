const ApiError = require('../error/api-error')
const logger = require("../modules/logger")
const {
    Part,
    PartType,
    OrderItemPart,
    OrderItem,
    Order, Address, Customer, Warehouse, Employee
} = require('../database/models')
const sequelize = require("../database/database");
const e = require("express");


class PartController
{
    async addNew(req, res, next)
    {
        try
        {
            logger.info("Call " + req.baseUrl + req.url)

            const d = new Date()
            const dd = String(d.getDate()).padStart(2, '0')
            const mm = String(d.getMonth() + 1).padStart(2, '0')
            const yy = String(d.getFullYear()).slice(-2)

            const {batch_number, warehouse_id, part_type_id} = req.body
            if (!batch_number || !warehouse_id || !part_type_id)
            {
                logger.warn("Invalid part information: " + JSON.stringify(req.body))
                return next(ApiError.badRequest("Incorrect request data"))
            }

            logger.info("Find part-type")
            const type = await PartType.findOne({where: {part_type_id}})
            if (!type)
            {
                logger.warn("Part-type not found")
                return next(ApiError.badRequest("Part type not found"))
            }

            logger.info("Getting part number")
            const [[{queue}]] = await sequelize.query("SELECT nextval('\"Parts_part_id_seq\"') as queue;")

            logger.info("Creating new part")
            const part = await Part.create({
                serial_number: `SN-${type.dataValues.type_code.toUpperCase()}${dd}${mm}${yy}H${queue}`,
                batch_number: batch_number,
                manufacture_date: new Date(),
                warehouse_id: warehouse_id,
                part_type_id: part_type_id
            })

            logger.done("Sending response")
            return res.json(part)
        }
        catch(e)
        {
            logger.error(e)
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findAll(req, res, next)
    {
        try
        {
            logger.info("Call " + req.baseUrl + req.url)
            const {limit, offset} = req.query

            logger.info("Getting all parts")
            const parts = await Part.findAndCountAll({limit, offset, include: [
                    {model: Warehouse, as: 'warehouse', include: [{model: Address, as: 'address'}]},
                    {model: Employee, as: 'employee', attributes: ["employee_id", "first_name", "last_name", "middle_name", "role"]},
                    {model: PartType, as: 'partType'},
                    {model: OrderItemPart, as: 'orderItemPart', attributes: ["order_item_id"], include: [{
                        model: OrderItem, as: 'orderItem', attributes: ["order_id"], include: [{
                            model: Order, as: 'order'
                        }]
                    }]}
                ]})

            logger.done("Sending response")
            return res.json(parts)
        }
        catch(e)
        {
            logger.error(e)
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findOne(req, res, next)
    {
        try
        {
            logger.info("Call " + req.baseUrl + req.url)
            const {id} = req.params

            logger.info("Getting part")
            const part = await Part.findOne({
                where: {part_id: id},
                include: [{model: PartType, as: "partType"}],
            })
            if(part)
            {
                logger.done("Sending response")
                return res.json(part.dataValues)
            }
            else
            {
                logger.error("Part not found")
                return next(ApiError.notFound('Part not found'))
            }
        }
        catch(e)
        {
            logger.error(e)
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async remove(req, res, next)
    {
        try
        {
            logger.info("Call " + req.baseUrl + req.url)
            const {id} = req.body

            logger.info("Removing part")
            await Part.destroy({where: {part_id: id}})

            logger.done("Sending response")
            return res.json({message: 'Ok'})
        }
        catch(e)
        {
            logger.error(e)
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async changeOrder(req, res, next)
    {
        try
        {
            logger.info("Call " + req.baseUrl + req.url)
            const {part_id} = req.params
            const {order_id} = req.body

            const part = await Part.findOne({where: {part_id}})
            if(!part)
            {
                logger.warn("Part not found")
                return next(ApiError.notFound('Part not found'))
            }

            if(order_id)
            {
                logger.info("Changing part's order")

                logger.info("Find order")
                const order = await Order.findByPk(order_id, {
                    include: [{model: OrderItem, as: "orderItems"}],
                })

                if(!order)
                {
                    logger.warn("Order not found")
                    return next(ApiError.notFound('Order not found'))
                }

                logger.info("Select order-item")
                let orderItemId = -1
                for(let orderItem of order["orderItems"])
                {
                    if(orderItem.part_type_id === part.part_type_id)
                    {
                        orderItemId = orderItem.order_item_id
                        break
                    }
                }

                if(orderItemId < 0)
                {
                    logger.warn("Order-item not found")
                    return next(ApiError.notFound('OrderItem not found'))
                }

                logger.info("Changing order")
                await OrderItemPart.destroy({where: {part_id}})
                await OrderItemPart.create({
                    order_item_id: orderItemId,
                    part_id: part_id
                })

                logger.done("Sending response")
                return res.json({order})
            }
            await OrderItemPart.destroy({where: {part_id}})
            return res.json({order: null})
        }
        catch(e)
        {
            logger.error(e)
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findOrders(req, res, next)
    {
        try
        {
            logger.info("Call " + req.baseUrl + req.url)
            const {part_id} = req.params

            logger.info("Getting orders")
            const part = await Part.findOne({
                where: {part_id},
                attributes: ["part_id"],
                include: [{
                    model: PartType, as: "partType", attributes: ["part_type_id"], include: [{
                        model: OrderItem, as: "orderItems", attributes: ["order_item_id", "order_id"], include: [{
                            model: Order, as: "order", include: [{
                                model: Customer, as: "customer", include: [{
                                    model: Address, as: "address"
                                }]
                            }]
                        }]
                    }]}],
            })
            if(!part)
            {
                logger.warn("Part not found")
                return next(ApiError.notFound('Part not found'))
            }

            logger.info("Sort orders")
            const request = {}
            for(const orderItem of part?.partType?.orderItems)
            {
                request[orderItem.order.order_id] = orderItem.order
            }

            logger.done("Sending response")
            return res.json(Object.keys(request).map(key => request[key]))
        }
        catch(e)
        {
            logger.error(e)
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new PartController()
