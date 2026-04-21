from typing import TypedDict, Optional

from controller.api.http import HttpWrapper


class PartTypesApi:
    def __init__(self, client: HttpWrapper):
        self.c = client

    class Types(TypedDict):
        part_type_id: int
        name: str
        type_code: str
        price: int
        order_item_type_id: Optional[int]

    class AllDetailsResponse(TypedDict):
        count: int
        rows: list['PartTypesApi.Types']


    async def get_all(self) -> AllDetailsResponse:
        return await self.c.get("/api/part-type/")

    async def get(self, id: int) -> Types:
        return await self.c.get(f"/api/part-type/{id}")
