import asyncio
import logging
from autogen_ext.models.openai import OpenAIChatCompletionClient
from autogen_agentchat.agents import AssistantAgent,CodeExecutorAgent,UserProxyAgent
from autogen_agentchat.teams import MagenticOneGroupChat
from autogen_agentchat.ui import Console
from autogen_agentchat.base import TaskResult
from autogen_ext.agents.web_surfer import MultimodalWebSurfer
from autogen_ext.agents.magentic_one import MagenticOneCoderAgent
from autogen_ext.code_executors.local import LocalCommandLineCodeExecutor
from autogen_agentchat import EVENT_LOGGER_NAME, TRACE_LOGGER_NAME



logging.basicConfig(level=logging.WARNING)

# For trace logging.
trace_logger = logging.getLogger(TRACE_LOGGER_NAME)
trace_logger.addHandler(logging.StreamHandler())
trace_logger.setLevel(logging.ERROR)

# For structured message logging, such as low-level messages between agents.
event_logger = logging.getLogger(EVENT_LOGGER_NAME)
event_logger.addHandler(logging.StreamHandler())
event_logger.setLevel(logging.ERROR)


model_client = OpenAIChatCompletionClient(
    model="deepseek-chat",
    base_url="https://api.deepseek.com/v1",
    model_info={
        "vision": False,
        "function_calling": True,
        "json_output": True,
        "family": "unknown",
    },
)


agent = AssistantAgent(
    name="planer_agent",
    model_client=model_client,
    #tools=[get_weather],
    system_message="You are a planer agent. You get task from user and plan a solution to solve the task.",
    #human_input_mode="ALWAYS",
    reflect_on_tool_use=True,
    model_client_stream=True,  # Enable streaming tokens from the model client.
)



async def main() -> None:
    surfer = MultimodalWebSurfer(
        "WebSurfer",
        model_client=model_client,
    )

    coder = MagenticOneCoderAgent(
        "Coder",
        model_client=model_client,
    )
    terminal = CodeExecutorAgent("ComputerTerminal",code_executor=LocalCommandLineCodeExecutor())
    user_proxy = UserProxyAgent("user_proxy", input_func=input)
    team = MagenticOneGroupChat([user_proxy, surfer, coder, terminal], model_client=model_client)
    while True:
        task = await asyncio.get_event_loop().run_in_executor(None, input, "what can i do for: ")
        #print(task)
        await Console(team.run_stream(task=task),output_stats=True)
        await team.reset()

asyncio.run(main())