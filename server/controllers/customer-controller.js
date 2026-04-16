const ApiError = require('../error/api-error')
const {Customer, Address} = require('../database/models')

class CustomerController
{
    async addNew(req, res)
    {
        try
        {
            const {company_name, inn, ogrn, address_id} = req.body
            if (!company_name || !inn || !ogrn || !address_id)
            {
                return res.json(ApiError.badRequest("Incorrect request data"))
            }

            const [customer] = await Customer.findOrCreate({
                where: { company_name, inn, ogrn, address_id },
                defaults: { company_name, inn, ogrn, address_id },
                include: [{ model: Address, as: 'address' }]
            })

            return res.json(customer)
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findAll(req, res)
    {
        try
        {
            const customers = await Customer.findAndCountAll({include: [{ model: Address, as: 'address' }]})
            return res.json(customers)
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async findOne(req, res)
    {
        try
        {
            const {id} = req.params
            const customer = await Customer.findOne({where: {customer_id: id}, include: [{ model: Address, as: 'address' }]})
            return res.json(customer ? customer.dataValues : ApiError.notFound('Customer not found'))
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async remove(req, res)
    {
        try
        {
            const {id} = req.body
            await Customer.destroy({where: {customer_id: id.toString()}})
            return res.json({status: 200, message: 'Ok'})
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new CustomerController()