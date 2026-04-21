const ApiError = require('../error/api-error')
const {Order, Customer, OrderItem, PartType, Part, OrderItemPart} = require('../database/models')
const sequelize = require('../database/database')
const { Sequelize, Op } = require('sequelize')

class OrderController
{
    async addNew(req, res, next)
    {
        try
        {
            const d = new Date()
            const dd = String(d.getDate()).padStart(2, '0')
            const mm = String(d.getMonth() + 1).padStart(2, '0')
            const yy = String(d.getFullYear()).slice(-2)

            const {customer_id, notes, priority} = req.body
            if (!customer_id || !notes)
            {
                return next(ApiError.badRequest("Incorrect request data"))
            }

            const [[{queue}]] = await sequelize.query("SELECT nextval('\"Orders_order_id_seq\"') as queue;")
            const order = await Order.create({
                customer_id,
                notes,
                priority,
                order_number: `${dd}${mm}${yy}H${queue}`
            })
            const customer = await Customer.findOne({where: {customer_id}})
            order.dataValues.customer = customer?.dataValues

            return res.json(order)
        }
        catch(e)
        {
            return next(ApiError.internal('Registration error: ' + e.message))
        }
    }

    async addItem(req, res, next)
    {
        try
        {
            const {order_id, part_type_id, required_quantity } = req.body
            if (!order_id || !part_type_id || !required_quantity)
            {
                return next(ApiError.badRequest("Incorrect request data"))
            }

            const order = await Order.findByPk(order_id)
            if (!order)
            {
                return next(ApiError.notFound("Order not found"))
            }

            const item = await OrderItem.create({
                order_id,
                part_type_id,
                required_quantity
            })

            return res.json(item)
        }
        catch(e)
        {
            return next(ApiError.internal('Registration error: ' + e.message))
        }
    }

    async findAll(req, res, next)
    {
        try
        {
            let {limit, offset} = req.query
            console.log("limit", limit)
            console.log("offset", offset)
            limit = parseInt(limit) || 20
            offset = parseInt(offset) || 0

            const {count, rows} = await Order.findAndCountAll({
                limit,
                offset,
                distinct: true,
                attributes: {
                    include: [
                        [
                            sequelize.cast(sequelize.literal(`(
                                SELECT SUM(price)
                                FROM "Order_Items" AS orderItems
                                WHERE
                                    orderItems.order_id = "order".order_id
                            )`), "float"),
                            'fullPrice'
                        ]
                    ]
                },
                include: [
                    {
                        model: Customer,
                        as: 'customer',
                        attributes: ['customer_id', 'company_name']
                    },
                    {
                        model: OrderItem,
                        as: 'orderItems',
                        include: [
                            {
                                model: PartType,
                                as: 'partType',
                                attributes: ['part_type_id', 'name', 'price']
                            },
                            {
                                model: OrderItemPart,
                                as: 'orderItemParts',
                                include: [
                                    {
                                        model: Part,
                                        as: 'part',
                                        attributes: ['part_id', 'serial_number', 'batch_number']
                                    }
                                ]
                            }
                        ]
                    }
                ],
                order: [['created_at', 'DESC']]
            })

            return res.json({count, rows})
        }
        catch(e)
        {
            return next(ApiError.internal('Fetch error: ' + e.message))
        }
    }

    async findOne(req, res, next)
    {
        try
        {
            const {id} = req.params
            const order = await Order.findByPk(id, {
                attributes: {
                    include: [
                        [
                            sequelize.cast(sequelize.literal(`(
                                SELECT SUM(price)
                                FROM "Order_Items" AS orderItems
                                WHERE
                                    orderItems.order_id = "order".order_id
                            )`), "float"),
                            'fullPrice'
                        ]
                    ]
                },
                include: [
                    {
                        model: Customer,
                        as: 'customer',
                        attributes: ['customer_id', 'company_name']
                    },
                    {
                        model: OrderItem,
                        as: 'orderItems',
                        include: [
                            {
                                model: PartType,
                                as: 'partType',
                                attributes: ['part_type_id', 'name', 'price']
                            },
                            {
                                model: OrderItemPart,
                                as: 'orderItemParts',
                                include: [
                                    {
                                        model: Part,
                                        as: 'part',
                                        attributes: ['part_id', 'serial_number', 'batch_number']
                                    }
                                ]
                            }
                        ]
                    }
                ]
            })

            if (!order)
            {
                return next(ApiError.notFound("Order not found"))
            }

            return res.json(order)
        }
        catch(e)
        {
            return next(ApiError.internal('Fetch error: ' + e.message))
        }
    }

    async remove(req, res, next)
    {
        try
        {
            const {id} = req.params
            const order = await Order.findByPk(id)
            if (!order)
            {
                return next(ApiError.notFound("Order not found"))
            }

            await order.destroy()
            return res.json({message: "Ok"})
        }
        catch(e)
        {
            return next(ApiError.internal('Delete error: ' + e.message))
        }
    }

    async deleteItem(req, res, next)
    {
        try
        {
            const {id} = req.params
            const item = await OrderItem.findByPk(id)
            if (!item)
            {
                return next(ApiError.notFound("Item not found"))
            }

            await item.destroy()
            return res.json({message: "Ok"})
        }
        catch(e)
        {
            return next(ApiError.internal('Delete error: ' + e.message))
        }
    }

}

module.exports = new OrderController()
