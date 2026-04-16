const {Op} = require('sequelize');

const ApiError = require('../error/api-error')
const {OrderItemPart, Part, PartType, Employee, Warehouse, Address, OrderItem,
    Order, Customer} = require('../database/models')


class ScanController
{
    async handleNNResponse(req, res)
    {
        const {serial_number, batch_number, manufacture_date} = req.body
        if (!serial_number || !batch_number || !manufacture_date)
        {
            return res.json(ApiError.badRequest("Incorrect request data"))
        }
        
        if (!await isPartAssignedToOrders(serial_number))
        {
            await assignPartToOrder(serial_number)
        }

        const partInfo = getAllInfoAboutPart(serial_number).toJSON()
        // Как отправить по WebSocket?

        return res.json(ApiError.ok())
    }

    async isPartAssignedToOrders(serial_number)
    {
        return await OrderItemPart.findAll({
            where: {
                serial_number: { [Op.eq]: serial_number },
            },
        }).length !== 0
    }

    async getAllInfoAboutPart(serial_number)
    {
        return await OrderItemPart.findOne({
            where: { serial_number: serial_number },
            attributes: [],
            include: [
                {
                    model: Part,
                    attributes: [
                        'part_id',
                        'serial_number',
                        'batch_number',
                        'manufacture_date',
                        'sorted_at',
                        'warehouse_id',
                        'qc_inspector_id',
                        'part_type_id',
                        'qc_status',
                        'status'
                    ],
                    include: [
                        {
                            model: Warehouse,
                            attributes: [
                                'warehouse_id',
                                'name',
                                'address_id'
                            ],
                            include: [
                                {
                                    model: Address,
                                    attributes: [
                                        'address_id',
                                        'country',
                                        'region',
                                        'city',
                                        'street',
                                        'building',
                                        'postal_code'
                                    ]
                                }
                            ]
                        },
                        {
                            model: Employee,
                            attributes: [
                                'employee_id',
                                'first_name',
                                'last_name',
                                'middle_name',
                                'role',
                                'login'
                            ]
                        },
                        {
                            model: PartType,
                            attributes: [
                                'part_type_id',
                                'name',
                                'type_code'
                            ]
                        }
                    ]
                },
                {
                    model: OrderItem,
                    attributes: [
                        'order_item_id',
                        'order_id',
                        'required_quantity',
                        'price'
                    ],
                    include: [
                        {
                            model: Order,
                            attributes: [
                                'order_id',
                                'order_number',
                                'status',
                                'notes',
                                'customer_id',
                                'created_at'
                            ],
                            include: [
                                {
                                    model: Customer,
                                    attributes: [
                                        'customer_id',
                                        'company_name',
                                        'inn',
                                        'ogrn',
                                        'address_id'
                                    ],
                                    include: [
                                        {
                                            model: Address,
                                            attributes: [
                                                'address_id',
                                                'country',
                                                'region',
                                                'city',
                                                'street',
                                                'building',
                                                'postal_code'
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        })
    }

    async assignPartToOrder(serial_number)
    {
    }
}


module.exports = new ScanController()
