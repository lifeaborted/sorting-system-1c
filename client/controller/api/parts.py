from typing import TypedDict, Optional

from controller.api.http import HttpWrapper


class PartsApi:
    def __init__(self, client: HttpWrapper):
        self.c = client

    class Detail(TypedDict):
        part_id: int
        serial_number: str
        batch_number: str
        manufacture_date: str
        sorted_at: Optional[str]
        warehouse_id: Optional[int]
        qc_inspector_id: Optional[int]
        part_type_id: int
        status: str
        orderItemPart: 'PartsApi.OrderItemPartWrapper'

    class AllDetailsResponse(TypedDict):
        count: int
        rows: list['PartsApi.Detail']

    from typing import TypedDict, Optional

    class Order(TypedDict):
        order_id: int
        order_number: str
        customer_id: int
        priority: int
        status: str
        notes: Optional[str]
        created_at: str

    class OrderWrapper(TypedDict):
        order_id: int
        order: 'PartsApi.Order'


    class OrderItemPartWrapper(TypedDict):
        order_item_id: int
        orderItem: 'PartsApi.OrderWrapper'

    class Response(TypedDict):
        orderItemPart: 'PartsApi.OrderItemPartWrapper'

    async def get_all(self) -> AllDetailsResponse:
        return await self.c.get("/api/part/")

    async def get(self, id: int) -> Detail:
        return await self.c.get(f"/api/part/{id}")

    async def get_details_orders(self, id: int) -> list['PartsApi.Order']:
        return await self.c.get(f"/api/part/{id}/orders")

    async def change_detail_order(self, detail_id: int, order_id: Optional[int] = None) -> list['PartsApi.Order']:
        return await self.c.put(f"/api/part/{detail_id}/change-order", {
            "order_id": order_id
        })