const ApiError = require('../error/api-error')
const sequelize = require('../database/database')
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
            let isSorted = false
            const {serial_number, batch_number} = req.body
            const {image} = req.files
            if (!serial_number || !batch_number)
            {
                await socket.broadcast(JSON.stringify({status: 400, message: 'Incorrect request data'}))
                return next(ApiError.badRequest("Incorrect request data"))
            }
            
            const part = await Part.findOne({where: {serial_number, batch_number}})
            if(!part)
            {
                await socket.broadcast(JSON.stringify({status: 400, message: 'Bad Request'}))
                return next(ApiError.badRequest("Part not found"))
            }

            let inOrder = await OrderItemPart.findOne({where: {part_id: part.dataValues.part_id}})
            if(!inOrder)
            {
                inOrder = await this.sort(part.dataValues.part_id)
                if(!inOrder)
                {
                    await socket.broadcast(JSON.stringify({status: 404, message: 'No available orders found'}))
                    return next(ApiError.notFound("No available orders found"))
                }
                isSorted = true
            }

            const order = await Order.findOne({
                include: [{
                    model: OrderItem,
                    where: {order_item_id: inOrder.order_item_part_id},
                }], attributes: ['order_id', 'customer_id']
            })
            const fullOrder = await Order.findByPk(order.dataValues.order_id, {
                include: [{
                    model: OrderItem,
                    as: "orderItem",
                    required: false,
                    include: [{
                        model: OrderItemPart,
                        as: "orderItemPart",
                        required: false,
                        include: [{
                            model: Part,
                            as: "part",
                            required: false
                        }]
                    }]
                }]
            })
            const customer = await Customer.findOne({
                where: {customer_id: order.dataValues.customer_id},
                include: [{model: Address, as: 'address'}]
            })

            await socket.broadcast(JSON.stringify({
                status: 200,
                part: part.dataValues,
                order: fullOrder,
                customer: customer.dataValues,
                isSorted: isSorted,
                image: image
            }))

            return res.json({message: "Ok"})
        }
        catch(e)
        {
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async sort(part_id)
    {
        return null
        // Тут код от нейронки, не работочий, проблема в SQL запросе, надо подогнать под имена таблиц и протестировать

        // const transaction = await sequelize.transaction({isolationLevel: sequelize.Transaction.ISOLATION_LEVELS.SERIALIZABLE})
        // const part = await Part.findByPk(part_id, {lock: transaction.LOCK.UPDATE, transaction})
        //
        // if (!part) return null
        //
        // const partTypeId = part.part_type_id;
        // const candidates = await sequelize.query(`
        //     WITH order_item_fulfillment AS (
        //         SELECT
        //             oi.order_item_id,
        //             oi.order_id,
        //             oi.required_quantity,
        //             COALESCE(COUNT(oip.part_id), 0) AS fulfilled_qty
        //         FROM "Order_Items" oi
        //         LEFT JOIN "Order_Item_Parts" oip ON oi.order_item_id = oip.order_item_id
        //         WHERE oi.part_type_id = :partTypeId
        //         GROUP BY oi.order_item_id
        //         HAVING COALESCE(COUNT(oip.part_id), 0) < oi.required_quantity
        //     ),
        //     order_total_work AS (
        //         SELECT
        //             o.order_id,
        //             o.priority,
        //             SUM(oi2.required_quantity) AS total_required
        //         FROM "Orders" o
        //         JOIN "Order_Items" oi2 ON o.order_id = oi2.order_id
        //         GROUP BY o.order_id
        //     )
        //     SELECT
        //         oif.order_item_id,
        //         oif.order_id,
        //         otw.priority,
        //         otw.total_required
        //     FROM order_item_fulfillment oif
        //     JOIN order_total_work otw ON oif.order_id = otw.order_id
        //     ORDER BY
        //         otw.priority ASC,
        //         otw.total_required ASC
        //     LIMIT 1
        //     FOR UPDATE OF oif SKIP LOCKED
        // `,
        // {
        //     replacements: { partTypeId },
        //     type: sequelize.QueryTypes.SELECT,
        //     transaction
        // })
        //
        // if (candidates.length === 0) return null
        //
        // const selected = candidates[0];
        // const orderItemId = selected.order_item_id;
        //
        // const orderItemPart = await OrderItemPart.create({
        //     order_item_id: orderItemId,
        //     part_id: part_id
        // }, { transaction })
        //
        // await part.update({
        //     status: 'sorted',
        //     sorted_at: sequelize.literal('NOW()')
        // }, { transaction })
        //
        //
        // const orderId = selected.order_id;
        // const orderItemsStatus = await sequelize.query(`
        //     SELECT
        //         oi.order_item_id,
        //         oi.required_quantity,
        //         COALESCE(COUNT(oip.part_id), 0) AS fulfilled_qty
        //     FROM "Order_Items" oi
        //     LEFT JOIN "Order_Item_Parts" oip ON oi.order_item_id = oip.order_item_id
        //     WHERE oi.order_id = :orderId
        //     GROUP BY oi.order_item_id
        // `,
        // {
        //     replacements: { orderId },
        //     type: sequelize.QueryTypes.SELECT,
        //     transaction
        // })
        //
        // const allItemsFulfilled = orderItemsStatus.every(item => Number(item.fulfilled_qty) >= item.required_quantity)
        //
        // if (allItemsFulfilled)
        // {
        //     await Order.update(
        //         { status: 'completed' },
        //         { where: { order_id: orderId }, transaction }
        //     )
        // }
        // await transaction.commit()
        // return orderItemPart



        // Дальше нейроночно-рукописный код, полурабочая версия, оставлю на всякий, пока не написали сортировку

        // const orders = await Order.findAll({
        //     include: [{
        //         model: OrderItem,
        //         include: [{
        //             model: OrderItemPart,
        //             where: { part_id: part_id },
        //             include: [{
        //                 model: Part,
        //                 where: { part_id: part_id },
        //                 required: true
        //             }],
        //             required: true
        //         }],
        //         required: true
        //     }],
        //     attributes: ['order_id', 'priority']
        // });
        //
        // if (orders.length === 0) return null
        //
        // const maxPriority = Math.max(...orders.map(order => order.priority))
        // const maxPriorityOrderIds = orders
        //     .filter(order => order.priority === maxPriority)
        //     .map(order => order.order_id)
        //
        // const orderItems = await OrderItem.findAll({
        //     where: {order_id: maxPriorityOrderIds},
        //     include: [{
        //         model: OrderItemPart,
        //         attributes: ['order_item_part_id'],
        //         required: false
        //     }, {
        //         model: Order,
        //         attributes: ['order_id', 'priority'],
        //         where: {order_id: maxPriorityOrderIds}
        //     }]
        // })
        //
        // const incompleteOrderItems = orderItems.filter(item => {
        //     const assignedPartsCount = item.OrderItemParts ? item.OrderItemParts.length : 0;
        //     return assignedPartsCount < item.required_quantity;
        // })
    }
}

module.exports = new ScanController()
