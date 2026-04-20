from typing import TypedDict, Optional

from controller.api.http import HttpWrapper


class WarehousesApi:
    def __init__(self, client: HttpWrapper):
        self.c = client

    class Address(TypedDict):
        address_id: int
        country: str
        region: str
        city: str
        street: str
        building: str
        postal_code: str

    class Warehouse(TypedDict):
        warehouse_id: int
        name: str
        address_id: int
        created_at: str
        address: WarehousesApi.Address

    class AllDetailsResponse(TypedDict):
        count: int
        rows: list[WarehousesApi.Warehouse]


    async def get_all(self) -> AllDetailsResponse:
        return await self.c.get("/api/warehouse/")

    async def get(self, id: int) -> Warehouse:
        return await self.c.get(f"/api/warehouse/{id}")
