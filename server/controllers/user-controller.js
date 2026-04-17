const ApiError = require('../error/api-error')
const {Employee} = require('../database/models')
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken')

class UserController
{
    async registration(req, res)
    {
        try
        {
            const { first_name, last_name, middle_name, role, login, password } = req.body
            if (!first_name || !last_name || !middle_name || !role || !login || !password)
            {
                return res.json(ApiError.badRequest("Incorrect request data"))
            }

            let user = await Employee.findOne({where: {login: login}})
            if(user)
            {
                return res.json(ApiError.conflict('This login is already in use'))
            }

            const hashPassword = await bcrypt.hash(password + process.env.ENCRYPTION_SALT, 10)
            user = await Employee.create({
                first_name: first_name,
                last_name: last_name,
                middle_name: middle_name,
                role: role,
                login: login,
                password_hash: hashPassword
            })

            const token = jwt.sign(
                {id: user.dataValues.employee_id, role: user.dataValues.role},
                process.env.JWT_PASSWORD_CODE,
                {expiresIn: process.env.JWT_PASSWORD_DURATION + 'h'}
            )
            return res.json({token})
        }
        catch (e)
        {
            return res.json(ApiError.internal('Registration error: ' + e.message))
        }
    }

    async login(req, res)
    {
        try
        {
            const {login, password} = req.body
            if (!login || !password)
            {
                return res.json(ApiError.badRequest("Incorrect request data"))
            }

            const user = await Employee.findOne({where: {login}})
            if (!user)
            {
                return res.json(ApiError.badRequest('Incorrect authentication data'))
            }
            if (!user.dataValues.is_active)
            {
                return res.json(ApiError.forbidden('Employee has been deactivated'))
            }

            const isPassCorrect = await bcrypt.compare(password + process.env.ENCRYPTION_SALT, user.dataValues.password_hash)
            if (!isPassCorrect)
            {
                return res.json(ApiError.badRequest('Incorrect authentication data'))
            }

            const token = jwt.sign(
                {id: user.dataValues.employee_id, role: user.dataValues.role},
                process.env.JWT_PASSWORD_CODE,
                {expiresIn: process.env.JWT_PASSWORD_DURATION + 'h'}
            )
            return res.json({token})
        }
        catch (e)
        {
            return res.json(ApiError.internal('Login error: ' + e.message))
        }
    }

    async check(req, res)
    {
        try
        {
            const token = jwt.sign(
                {id: req.user.id, role: req.user.role},
                process.env.JWT_PASSWORD_CODE,
                {expiresIn: process.env.JWT_PASSWORD_DURATION + 'h'}
            )
            return res.json({token})
        }
        catch (e)
        {
            return res.json(ApiError.internal('Validate error: ' + e.message))
        }
    }

    async getAll(req, res)
    {
        try
        {
            const {limit = 20, offset = 0} = req.query
            const users = await Employee.findAndCountAll({limit, offset, attributes: [
                    "employee_id",
                    "first_name",
                    "last_name",
                    "middle_name",
                    "role",
                    "is_active",
                    "login",
                    "created_at",
                ]})
            return res.json(users)
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }

    async getOne(req, res)
    {
        try
        {
            const {id} = req.params
            if (isNaN(id))
            {
                return res.json(ApiError.badRequest("Incorrect request data"))
            }
            const user = await Employee.findOne({where: {employee_id: id}, attributes: [
                    "employee_id",
                    "first_name",
                    "last_name",
                    "middle_name",
                    "role",
                    "is_active",
                    "login",
                    "created_at"
                ]})

            if (user)
            {
                return res.json(user)
            }
            else
            {
                return res.json(ApiError.notFound('Employee not found'))
            }
        }
        catch (e)
        {
            return res.json(ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new UserController()
