from typing import TypedDict, Callable, Awaitable

from aiohttp import ClientWebSocketResponse

from controller.api.http import HttpWrapper


class UserApi:
    def __init__(self, client: HttpWrapper):
        self.c = client

    class RegisterRequest(TypedDict):
        first_name: str
        last_name: str
        middle_name: str
        role: str
        login: str
        password: str

    class LoginResponse(TypedDict):
        token: str
    async def register(self, data: RegisterRequest) -> LoginResponse:
        return await self.c.post("/api/user/register", data)

    class LoginRequest(TypedDict):
        login: str
        password: str
    async def login(self, data: LoginRequest) -> LoginResponse:
        return await self.c.post("/api/user/login", data)

    class MeResponse(TypedDict):
        employee_id: int
        first_name: str
        last_name: str
        middle_name: str
        role: str
        is_active: bool
        login: str
        created_at: str
    async def me(self) -> MeResponse:
        return await self.c.get("/api/user/me")

    async def detail_wss(self, f: Callable[[ClientWebSocketResponse], Awaitable[None]]) -> None:
        return await self.c.wss("/", f)