const ApiError = require('../error/api-error')
const {Customer, Address} = require('../database/models')

class CustomerController
{
    async addNew(req, res, next)
    {
        try
        {
            const {company_name, inn, ogrn, address_id} = req.body
            if (!company_name || !inn || !ogrn || !address_id)
            {
                return next(new ApiError.badRequest("Incorrect request data"))
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
            return next(new ApiError.internal('Request error: ' + e.message))
        }
    }

    async findAll(req, res, next)
    {
        try
        {
            const customers = await Customer.findAndCountAll({include: [{ model: Address, as: 'address' }]})
            return res.json(customers)
        }
        catch (e)
        {
            return next(new ApiError.internal('Request error: ' + e.message))
        }
    }

    async findOne(req, res, next)
    {
        try
        {
            const {id} = req.params
            const customer = await Customer.findOne({where: {customer_id: id}, include: [{ model: Address, as: 'address' }]})
            if(customer)
            {
                return res.json(customer.dataValues)
            }
            else
            {
                return next(new ApiError.notFound('Customer not found'))
            }
        }
        catch (e)
        {
            return next(new ApiError.internal('Request error: ' + e.message))
        }
    }

    async remove(req, res, next)
    {
        try
        {
            const {id} = req.body
            await Customer.destroy({where: {customer_id: id.toString()}})
            return res.json({message: 'Ok'})
        }
        catch (e)
        {
            return next(new ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new CustomerController()