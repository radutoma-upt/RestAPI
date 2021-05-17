using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using Microsoft.Extensions.Configuration;

namespace RestApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RoleController : ControllerQuery
    {
        public RoleController(IConfiguration config, ILogger<RoleController> logger):
            base(config, logger) {}

        [HttpGet("{roleId}")]
        public async Task<JsonElement> Get(int roleId)
        {
            return await this.Query("get", this.GetType(), roleId);
        }

        [HttpPut]
        public async Task<JsonElement> Put([FromBody]JsonElement payload)
        {
            return await this.Query("put", this.GetType(), payload: payload);
        }

        [HttpPatch("{roleId}")]
        public async Task<JsonElement> Patch([FromBody]JsonElement payload, int roleId)
        {
            return await this.Query("patch", this.GetType(), roleId, payload);
        }

        [HttpDelete("{roleId}")]
        public async Task<JsonElement> Delete(int roleId)
        {
            return await this.Query("delete", this.GetType(), roleId);
        }
    }
}
