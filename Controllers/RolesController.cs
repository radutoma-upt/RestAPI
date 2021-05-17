using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using Microsoft.Extensions.Configuration;

namespace RestApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RolesController : ControllerQuery
    {
        public RolesController(IConfiguration config, ILogger<RolesController> logger):
            base(config, logger) {}

        [HttpGet]
        public async Task<JsonElement> Get()
        {
            return await this.Query("get", this.GetType());
        }
    }
}
