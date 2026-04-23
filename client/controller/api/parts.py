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
        order: 'PartsApi.OrderShort'

    class OrderShort(TypedDict):
        order_id: int
        order_number: str
    class AllDetailsResponse(TypedDict):
        count: int
        rows: list['PartsApi.Detail']


    async def get_all(self) -> AllDetailsResponse:
        return await self.c.get("/api/part/")

    # async def get(self, id: int) -> Detail:
    #     return await self.c.get(f"/api/part/{id}")