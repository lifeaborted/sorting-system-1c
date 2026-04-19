const ApiError = require('../error/api-error')
const {Employee} = require('../database/models')
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken')

class UserController
{
    async registration(req, res, next)
    {
        try
        {
            const { first_name, last_name, middle_name, role, login, password } = req.body
            if (!first_name || !last_name || !middle_name || !role || !login || !password)
            {
                return next(new ApiError.badRequest("Incorrect request data"))
            }

            let user = await Employee.findOne({where: {login: login}})
            if(user)
            {
                return next(new ApiError.conflict('This login is already in use'))
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
            return next(new ApiError.internal('Registration error: ' + e.message))
        }
    }

    async login(req, res, next)
    {
        try
        {
            const {login, password} = req.body
            if (!login || !password)
            {
                return next(new ApiError.badRequest("Incorrect request data"))
            }

            const user = await Employee.findOne({where: {login}})
            if (!user)
            {
                return res.json(ApiError.badRequest('Incorrect authentication data'))
            }
            if (!user.dataValues.is_active)
            {
                return next(new ApiError.forbidden('Employee has been deactivated'))
            }

            const isPassCorrect = await bcrypt.compare(password + process.env.ENCRYPTION_SALT, user.dataValues.password_hash)
            if (!isPassCorrect)
            {
                return next(new ApiError.badRequest('Incorrect authentication data'))
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
            return next(new ApiError.internal('Login error: ' + e.message))
        }
    }

    async check(req, res, next)
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
            return next(new ApiError.internal('Validate error: ' + e.message))
        }
    }

    async getAll(req, res, next)
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
            return next(ApiError.internal('Request error: ' + e.message))
        }
    }

    async aboutMe(req, res, next)
    {
        try
        {
            const user = await Employee.findOne({where: {employee_id: req.user.id}, attributes: [
                    "employee_id",
                    "first_name",
                    "last_name",
                    "middle_name",
                    "role",
                    "is_active",
                    "login",
                    "created_at"
                ]})
            return res.json(user)
        }
        catch (e)
        {
            return next(new ApiError.internal('Request error: ' + e.message))
        }
    }

    async getOne(req, res, next)
    {
        try
        {
            const {id} = req.params
            if (isNaN(id))
            {
                return next(new ApiError.badRequest("Incorrect request data"))
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
                return next(new ApiError.notFound('Employee not found'))
            }
        }
        catch (e)
        {
            return next(new ApiError.internal('Request error: ' + e.message))
        }
    }
}

module.exports = new UserController()
