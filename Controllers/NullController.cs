using System;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace RestApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NullController : ControllerBase
    {
        [HttpGet]
        public string Get()
        {
            var dummy = new {
                TimeStamp = DateTime.UtcNow
            };

            return JsonSerializer.Serialize(dummy);
        }
    }
}
