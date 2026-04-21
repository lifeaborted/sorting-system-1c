from typing import TypedDict, Optional

from controller.api.http import HttpWrapper


class OrdersApi:
    def __init__(self, client: HttpWrapper):
        self.c = client

    class Customer(TypedDict):
        customer_id: int
        company_name: str

    class Part(TypedDict):
        part_id: int
        serial_number: str
        batch_number: str

    class PartType(TypedDict):
        part_type_id: int
        name: str
        price: int

    class OrderItemPart(TypedDict):
        order_item_part_id: int
        order_item_id: int
        part_id: int
        part: 'OrdersApi.Part'

    class OrderItem(TypedDict):
        order_item_id: int
        order_id: int
        part_type_id: int
        required_quantity: int
        price: str
        partType: 'OrdersApi.PartType'
        orderItemParts: list['OrdersApi.OrderItemPart']

    class Order(TypedDict):
        order_id: int
        order_number: str
        customer_id: int
        priority: int
        status: str
        notes: Optional[str]
        created_at: str
        customer: 'OrdersApi.Customer'
        orderItems: list['OrdersApi.OrderItem']

    class AllOrdersResponse(TypedDict):
        count: int
        rows: list['OrdersApi.Order']


    async def get_all(self) -> AllOrdersResponse:
        return await self.c.get("/api/order/")

    async def get(self, id: int) -> 'OrdersApi.Order':
        return await self.c.get(f"/api/order/{id}")