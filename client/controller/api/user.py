from typing import TypedDict

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

