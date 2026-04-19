const ApiError = require('../error/api-error')
const {Order, Customer} = require('../database/models')
const sequelize = require('../database/database')

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
                return next(new ApiError.badRequest("Incorrect request data"))
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
            return next(new ApiError.internal('Registration error: ' + e.message))
        }
    }

    async addItem(req, res, next)
    {
        try
        {
            const {order_id, part_type_id, required_quantity } = req.body
        }
        catch(e)
        {
            return next(new ApiError.internal('Registration error: ' + e.message))
        }
    }

}

module.exports = new OrderController()
