const ApiError = require('../error/api-error')
const {Buffer} = require('buffer')
const {Op, NUMBER} = require('sequelize')
const logger = require('../modules/logger')
const socket = require('./service-controller')
const {OrderItemPart,
    Part,
    PartType,
    Employee,
    Warehouse,
    Address,
    OrderItem,
    Order,
    Customer} = require('../database/models')


class ScanController
{

    async scanCode(req, res, next)
    {
        try
        {
            logger.info("Call " + req.baseUrl + req.url)


            const {serial_number, batch_number} = req.body
            const {image} = req.files
            let isSorted = false
            let inOrderId = null
            let orderItemId = null

            if (!serial_number || !batch_number || !image)
            {
                logger.warn("Invalid scan information: " + JSON.stringify(req.body))
                await socket.broadcast(JSON.stringify({status: 400, message: 'Incorrect request data'}))
                return next(ApiError.badRequest("Incorrect request data"))
            }
            
            const part = await Part.findOne({where: {serial_number, batch_number}, include: [
                {model: PartType, as: "partType"},
                {model: Warehouse, as: "warehouse", include: [{
                    model: Address, as: "address"
                }]},
            ]})
            if(!part)
            {
                logger.warn("Part not found")
                await socket.broadcast(JSON.stringify({status: 400, message: 'Bad Request'}))
                return next(ApiError.badRequest("Part not found"))
            }

            logger.info("Determining order affiliation")
            const sorted = await OrderItemPart.findOne({where: {part_id: part.dataValues.part_id}, include: [{
                model: OrderItem, as: "orderItem", attributes: ["order_item_id", "order_id"], include: [{
                    model: Order, as: "order"
                }]
            }]})

            if(!sorted)
            {
                [inOrderId, orderItemId] = await this.sort(part.dataValues.part_id)
                if(!inOrderId)
                {
                    logger.warn("No available orders found")
                    await socket.broadcast(JSON.stringify({status: 404, message: 'No available orders found'}))
                    return next(ApiError.notFound("No available orders found"))
                }
                isSorted = true
            }
            else
            {
                logger.info("Part is already sorted")
                inOrderId = sorted.dataValues.orderItem.order.order_id
                orderItemId = sorted.dataValues.orderItem.order_item_id
            }

            const order = await Order.findOne({where: {order_id: inOrderId}, include: [{
                model: OrderItem, as: "orderItems", include: [{
                    model: PartType, as: "partType"
                }]},{
                model: Customer, as: "customer"
            }]})

            if(!order)
            {
                logger.warn("No available orders found")
                await socket.broadcast(JSON.stringify({status: 404, message: 'No available orders found'}))
                return next(ApiError.notFound("No available orders found"))
            }

            if(isSorted)
            {
                logger.info("Part has been sorted, saving data")

                part.qc_inspector_id = req.user.id
                await part.save()

                await OrderItemPart.create({
                    order_item_id: orderItemId,
                    part_id: part.dataValues.part_id
                })
            }

            logger.info("Sending WebSocket response")
            await socket.broadcast(req.user.id, JSON.stringify({
                status: 200,
                part: part.dataValues,
                order: order,
                isSorted: isSorted,
                image: {
                    name: image.name,
                    data: Buffer.from(image.data).toString('base64'),
                    mimetype: image.mimetype,
                    size: image.size
                }
            }))

            logger.done("Sending response")
            return res.json({message: "Ok"})
        }
        catch(e)
        {
            logger.error(e)
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async sort(part_id)
    {
        try
        {
            logger.info("Find all part orders")
            const orders = await Part.findOne({where: {part_id}, attributes: ["part_id"], include: [{
                model: PartType, as: "partType", attributes: ["part_type_id"], include: [{
                    model: OrderItem, as: "orderItems", attributes: ["order_item_id", "order_id", "required_quantity"], include: [{
                        model: Order, as: "order", attributes: ["order_id", "priority"], where: {
                            priority: {[Op.eq]: sequelize.literal('(SELECT MAX(priority) FROM "Orders")')},
                            status: "sorting"}
                }]}]
            }]})

            logger.info("Sorting orders")
            const orderList = {}
            for(let orderItem of orders?.partType?.orderItems)
            {
                if(!orderList[orderItem.order.order_id])
                {
                    orderList[orderItem.order.order_id] = {count: 0, order: orderItem.order, items: []}
                }
                orderList[orderItem.order.order_id].count += orderItem.required_quantity
                orderList[orderItem.order.order_id].items.push(orderItem)
            }

            if(Object.keys(orderList).length === 0)
            {
                logger.warn("Orders not found")
                return null
            }

            logger.info("Find min order")
            let minQuantity = 100000000
            let orderId = -1
            let orderItemId = -1
            for(let key of Object.keys(orderList))
            {
                if(minQuantity > orderList[key].count)
                {
                    minQuantity = orderList[key].count
                    orderId = key
                }
            }

            if(orderId < 0)
            {
                logger.warn("Orders with min quantity are not found")
                return null
            }

            logger.info("Find order-item")
            for(let item of orderList[orderId].items)
            {
                const count = await OrderItemPart.count({where: {order_item_id: item.order_item_id}})
                if(count >= item.required_quantity) continue
                orderItemId = item.order_item_id
            }

            if(orderItemId < 0)
            {
                logger.warn("Order-item with min quantity are not found")
                return null
            }

            logger.done("Sorting complete")
            return [parseInt(orderId), parseInt(orderItemId)]
        }
        catch(e)
        {
            logger.error(e)
            return null
        }
    }
}

module.exports = new ScanController()
