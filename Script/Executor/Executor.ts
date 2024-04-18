namespace Sen.Script.Executor {
    // The base need to be an object that is declared later

    export type Base = {
        [x: string]: unknown;
    } & {
        source: unknown;
    };

    // Base Configuration need to be inherited

    export interface Configuration {
        [x: string]: unknown;
    }

    export type MethodType = "file" | "directory" | "any" | "files";

    // Method Executor should implement direct forward, batch forward and async forward

    export interface MethodExecutor<
        Argument extends Sen.Script.Executor.Base,
        BatchArgument extends Sen.Script.Executor.Base,
        AsyncArgument extends Sen.Script.Executor.Base,
        Configuration extends Sen.Script.Executor.Configuration,
    > {
        id: string;
        configuration_file: string;
        direct_forward: (argument: Argument) => void;
        batch_forward?: (argument: BatchArgument) => void;
        is_enabled: boolean;
        configuration: Configuration;
        filter: [MethodType, RegExp] | [MethodType, ...Array<RegExp>];
    }

    /**
     * Forwarder typical type
     */

    export enum Forward {
        DIRECT,
        BATCH,
        ASYNC,
    }

    /**
     * Clock need to be initialized during the runtime.
     * Clock will calculate everything
     */

    export const clock: Sen.Script.Clock = new Clock();

    /**
     *
     * All methods are assigned here as key | value
     * Key: must be the id of the typical module
     * Value: the worker
     *
     */

    const methods: Map<string, Sen.Script.Executor.MethodExecutor<Sen.Script.Executor.Base, Sen.Script.Executor.Base, Sen.Script.Executor.Base, Sen.Script.Executor.Configuration>> = new Map();

    /**
     * ----------------------------------------------------------
     * JavaScript Implementation of Executor
     * @param worker - Here, we assign worker with the typical
     * object that has been declared
     * @returns - and so, the typical method will be assign
     * if the key is not found
     * ----------------------------------------------------------
     */

    export function push_as_module<
        Argument extends Sen.Script.Executor.Base,
        BatchArgument extends Sen.Script.Executor.Base,
        AsyncArgument extends Sen.Script.Executor.Base,
        Configuration extends Sen.Script.Executor.Configuration,
    >(worker: MethodExecutor<Argument, BatchArgument, AsyncArgument, Configuration>): void {
        const primary_id: string = worker.id!;
        delete (worker as any).id;
        if (methods.get(primary_id) !== undefined) {
            throw new Error(`${primary_id} is already existed`);
        }
        methods.set(primary_id, worker as MethodExecutor<Base, Base, Base, Configuration>);
        return;
    }

    /**
     * ----------------------------------------------------------
     * JavaScript Executor Implement
     * @param argument - Argument to query
     * @param key - Key
     * @param defined_value - If not, this val will assign to it
     * @returns
     * ----------------------------------------------------------
     */

    export function defined_or_default<Argument extends Sen.Script.Executor.Base, T>(argument: Argument, key: string, defined_value: T): void {
        if ((argument as any & Argument)[key] === undefined) {
            (argument as any & Argument)[key] = defined_value;
        }
        return;
    }

    /**
     * ----------------------------------------------------------
     * JavaScript Executor Implement
     * @param argument - Argument to query
     * @param key - Key
     * @param defined_value - If not, this val will assign to it
     * @returns
     * ----------------------------------------------------------
     */

    export function load_bigint<Argument extends Sen.Script.Executor.Base, Configuration extends Sen.Script.Executor.Configuration>(
        argument: Argument,
        key: keyof Argument & keyof Configuration,
        configuration: Configuration,
        rule: Array<bigint> | Array<[bigint, string | bigint, string]> | Array<string>,
        title: string,
    ): void {
        Sen.Script.Console.argument(title);
        if ((argument as any & Argument)[key] !== undefined) {
            if ((rule as Array<[bigint, string, string]>).map((e) => e[1]).includes((argument as any)[key])) {
                if (Shell.is_gui) {
                    Sen.Kernel.Console.print(argument[key] as string);
                } else {
                    Sen.Kernel.Console.print(`    ${argument[key]}`);
                }
            } else {
                Console.warning(format(Kernel.Language.get("script.invalid_input_data"), argument[key]));
                delete (argument as any & Argument)[key];
                return load_bigint(argument, key, configuration, rule, title);
            }
            return;
        }
        if ((configuration as any)[key] === "?") {
            return configurate_or_input(argument, key as string, rule as Array<[bigint, string, string]>);
        }
        if (configuration[key] !== "?") {
            if (rule.includes(configuration[key] as unknown as bigint & string)) {
                if (Shell.is_gui) {
                    Sen.Kernel.Console.print(configuration[key] as string);
                } else {
                    Sen.Kernel.Console.print(`    ${configuration[key]}`);
                }
                (argument as any & Argument)[key] = configuration[key];
                return;
            } else {
                Console.error(format(Kernel.Language.get("invalid.argument"), configuration[key]));
                (configuration as any)[key] = "?";
                return load_bigint(argument, key, configuration, rule, title);
            }
        }
        return;
    }

    /**
     * ----------------------------------------------------------
     * JavaScript Executor Implement
     * @param argument - Argument to query
     * @param key - Key
     * @param defined_value - If not, this val will assign to it
     * @returns
     * ----------------------------------------------------------
     */

    export function input_range<Argument extends Sen.Script.Executor.Base, Configuration extends Sen.Script.Executor.Configuration>(
        argument: Argument,
        key: keyof Argument & keyof Configuration,
        configuration: Configuration,
        rule: [bigint, bigint],
        title: string,
    ): void {
        Sen.Script.Console.argument(title);
        if ((argument as any & Argument)[key] !== undefined) {
            if (((argument as any & Argument)[key] as bigint) <= rule[1] && ((argument as any & Argument)[key] as bigint) >= rule[0]) {
                if (Shell.is_gui) {
                    Sen.Kernel.Console.print(argument[key] as string);
                } else {
                    Sen.Kernel.Console.print(`    ${argument[key]}`);
                }
            } else {
                Console.warning(format(Kernel.Language.get("script.invalid_input_data"), argument[key]));
                delete argument[key];
                return input_range(argument, key, configuration, rule, title);
            }
            return;
        }
        if ((configuration as any)[key] === "?") {
            let input: string = undefined!;
            while (true) {
                input = Kernel.Console.readline();
                if (/\d+/.test(input) && rule[0] <= BigInt(input) && rule[1] >= BigInt(input)) {
                    break;
                }
                Console.error(format(Kernel.Language.get("invalid.argument"), input));
            }
            (argument as any)[key] = BigInt(input);
            return;
        }
        if (configuration[key] !== "?") {
            if (/\d+/.test(configuration[key] as string) && rule[0] <= BigInt(configuration[key] as string) && rule[1] >= BigInt(configuration[key] as string)) {
                if (Shell.is_gui) {
                    Sen.Kernel.Console.print(configuration[key] as string);
                } else {
                    Sen.Kernel.Console.print(`    ${configuration[key]}`);
                }
                (argument as any & Argument)[key] = BigInt(configuration[key] as string);
                return;
            } else {
                Console.error(format(Kernel.Language.get("invalid.argument"), configuration[key]));
                (configuration as any)[key] = "?";
                return load_bigint(argument, key, configuration, rule, title);
            }
        }
        return;
    }

    /**
     * ----------------------------------------------------------
     * JavaScript Executor Implement
     * @param argument - Argument to query
     * @param key - Key
     * @param defined_value - If not, this val will assign to it
     * @returns
     * ----------------------------------------------------------
     */

    export function load_string<Argument extends Sen.Script.Executor.Base, Configuration extends Sen.Script.Executor.Configuration>(
        argument: Argument,
        key: keyof Argument & keyof Configuration,
        configuration: Configuration,
        title: string,
        rule?: Array<string>,
    ): void {
        Sen.Script.Console.argument(title);
        if ((argument as any & Argument)[key] !== undefined) {
            if (rule !== undefined && !rule.includes(argument[key] as string)) {
                Console.warning(format(Kernel.Language.get("script.invalid_input_data"), argument[key]));
                delete argument[key];
                return load_string(argument, key, configuration, title, rule);
            }
            if (Shell.is_gui) {
                Sen.Kernel.Console.print(`${argument[key]}`);
            } else {
                Sen.Kernel.Console.print(`    ${argument[key]}`);
            }
            return;
        }
        if ((configuration as any)[key] === "?") {
            (argument as any)[key] = Kernel.Console.readline();
            return;
        }
        if (configuration[key] !== "?") {
            if (!rule) {
                if (Shell.is_gui) {
                    Sen.Kernel.Console.print(`${configuration[key]}`);
                } else {
                    Sen.Kernel.Console.print(`    ${configuration[key]}`);
                }
                (argument as any & Argument)[key] = configuration[key];
                return;
            }
            if (rule.includes(configuration[key] as string)) {
                if (Shell.is_gui) {
                    Sen.Kernel.Console.print(`${configuration[key]}`);
                } else {
                    Sen.Kernel.Console.print(`    ${configuration[key]}`);
                }
                (argument as any & Argument)[key] = configuration[key];
                return;
            } else {
                Console.error(format(Kernel.Language.get("invalid.argument"), configuration[key]));
                (configuration as any)[key] = "?";
                return load_string(argument, key, configuration, title, rule);
            }
        }
        return;
    }

    /**
     * ----------------------------------------------------------
     * JavaScript Executor Implement
     * @param argument - Argument to query
     * @param key - Key
     * @param defined_value - If not, this val will assign to it
     * @returns
     * ----------------------------------------------------------
     */

    export function load_boolean<Argument extends Sen.Script.Executor.Base, Configuration extends Sen.Script.Executor.Configuration>(
        argument: Argument,
        key: keyof Argument & keyof Configuration,
        configuration: Configuration,
        title: string,
    ): void {
        Sen.Script.Console.argument(title);
        if ((argument as any & Argument)[key] !== undefined) {
            if (!(typeof argument[key] === "boolean")) {
                Console.warning(format(Kernel.Language.get("script.invalid_input_data"), argument[key]));
                delete argument[key];
                return load_boolean(argument, key, configuration, title);
            }
            if (Shell.is_gui) {
                Sen.Kernel.Console.print(`${argument[key]}`);
            } else {
                Sen.Kernel.Console.print(`    ${argument[key]}`);
            }
            return;
        }
        if ((configuration as any)[key] === "?") {
            (argument as any)[key] = input_boolean();
            return;
        }
        if (configuration[key] !== "?") {
            if (/^(true|false)$/.test(configuration[key] as string)) {
                if (Shell.is_gui) {
                    Sen.Kernel.Console.print(`${configuration[key]}`);
                } else {
                    Sen.Kernel.Console.print(`    ${configuration[key]}`);
                }
                (argument as any & Argument)[key] = Boolean(configuration[key]);
                return;
            }
            Console.send(`1. ${Kernel.Language.get("input.invalid_boolean_configuration")}`);
            (configuration as any)[key] = "?";
            return load_boolean(argument, key, configuration, title);
        }
        return;
    }

    export function input_boolean(): boolean {
        if (Shell.is_gui) {
            Kernel.Console.print(`1. ${Kernel.Language.get("input.set_argument_to_true")}`);
            Kernel.Console.print(`2. ${Kernel.Language.get("input.set_argument_to_false")}`);
        } else {
            Kernel.Console.print(`    1. ${Kernel.Language.get("input.set_argument_to_true")}`);
            Kernel.Console.print(`    2. ${Kernel.Language.get("input.set_argument_to_false")}`);
        }
        const result = input_integer([1n, 2n]);
        return result === 1n;
    }

    /**
     *
     * @param rule - Rule to filter
     * @returns Input in rule
     */

    export function input_integer(rule: Array<bigint>): bigint {
        let input: string = undefined!;
        if (Shell.is_gui) {
            input = Sen.Kernel.Console.readline();
        } else {
            while (true) {
                input = Sen.Kernel.Console.readline();
                if (/^\d+$/.test(input) && (rule as Array<bigint>).includes(BigInt(input))) {
                    break;
                }
                Console.error(Sen.Kernel.Language.get("js.invalid_input_value"));
            }
        }
        return BigInt(input);
    }

    /**
     * ----------------------------------------------------------
     * JavaScript Executor Implement
     * @param argument - Argument to query
     * @param key - Key
     * @param defined_value - If not, this val will assign to it
     * @returns
     * ----------------------------------------------------------
     */

    export function configurate_or_input<Argument extends Sen.Script.Executor.Base, T>(argument: Argument, key: keyof Argument, rule: Array<bigint> | Array<[bigint, string, string]>): void {
        if ((argument as any & Argument)[key] === undefined) {
            if (typeof rule[0] === "object") {
                const new_rule: Array<bigint> = [];
                rule.forEach(function make_rule(e: [bigint, string] & any): void {
                    if (Shell.is_gui) {
                        Sen.Kernel.Console.print(`${e[0]}. ${e[2]}`);
                    } else {
                        Sen.Kernel.Console.print(`    ${e[0]}. ${e[2]}`);
                    }
                    new_rule.push(e[0]);
                });
                (argument as any)[key] = (rule as Array<[bigint, string, string]>)[Number(input_integer(new_rule) - 1n)][1];
                return;
            }
            if (typeof rule[0] === "string") {
                (argument as any)[key] = Sen.Kernel.Console.readline();
                return;
            }
            if (typeof rule[0] === "bigint") {
                (argument as any)[key] = input_integer(rule as Array<bigint>);
                return;
            }
        }
        return;
    }

    /**
     * JS Filter
     * @param param0 - Type
     * @param source - Source file to test
     * @returns Filter
     */

    export function test([type, pattern]: [MethodType, RegExp], source: string): boolean {
        let is_valid: boolean = undefined!;
        switch (type) {
            case "file": {
                is_valid = Kernel.FileSystem.is_file(source);
                break;
            }
            case "directory": {
                is_valid = Kernel.FileSystem.is_directory(source);
                break;
            }
            case "any": {
                is_valid = true;
            }
        }
        is_valid &&= pattern.test(source);
        return is_valid;
    }

    export function test_array([type, ...method]: [MethodType, ...Array<RegExp>], source: Array<string>): boolean {
        let is_valid: boolean = true;
        switch (type) {
            case "file": {
                is_valid = source.every(function make_assert(e: string): boolean {
                    return Kernel.FileSystem.is_file(e);
                });
                break;
            }
            case "directory": {
                is_valid = source.every(function make_assert(e: string): boolean {
                    return Kernel.FileSystem.is_directory(e);
                });
                break;
            }
            case "any": {
                is_valid = true;
            }
        }
        return (
            is_valid &&
            method.every(function make_assert(e: RegExp): boolean {
                return source.some(function make_some(i: string): boolean {
                    return e.test(i);
                });
            })
        );
    }

    /**
     * ----------------------------------------------------------
     * JavaScript Implementation of Runner
     * @param id - Here, we call the id. If the id is assigned
     * as a method, the method will be called instantly
     * @param argument - Provide arguments
     * @param forward_type - Forwarder type
     * @returns - Launch if the method found.
     * If an error is thrown, it mean the id is not assigned
     * ----------------------------------------------------------
     */

    export function run_as_module<Argument extends Sen.Script.Executor.Base>(id: string, argument: Argument, forward_type: Sen.Script.Executor.Forward): void {
        const worker: Sen.Script.Executor.MethodExecutor<Sen.Script.Executor.Base, Sen.Script.Executor.Base, Sen.Script.Executor.Base, Sen.Script.Executor.Configuration> | undefined = methods.get(id);
        if (worker === undefined) {
            throw new Error(Sen.Script.format(Sen.Kernel.Language.get("js.method_not_found"), id));
        }
        worker.configuration = Sen.Kernel.JSON.deserialize_fs<Configuration>(worker.configuration_file);
        Sen.Script.Console.display(`${Sen.Kernel.Language.get("method_loaded")}`, `${Sen.Kernel.Language.get(id)} | ${id}`, Sen.Script.Definition.Console.Color.GREEN);
        switch (forward_type) {
            case Sen.Script.Executor.Forward.BATCH: {
                if (worker.batch_forward === undefined) {
                    throw new Error(Sen.Script.format(Sen.Kernel.Language.get("method_does_not_support_batch_implementation"), id));
                }
                worker.batch_forward(argument);
                break;
            }
            case Sen.Script.Executor.Forward.DIRECT: {
                worker.direct_forward(argument);
                break;
            }
            default: {
                throw new Error(Sen.Script.format(Sen.Kernel.Language.get("js.method_does_not_execute")));
            }
        }
        Sen.Script.Executor.clock.stop_safe();
        Sen.Script.Console.send(`${Sen.Kernel.Language.get("execution_time")}: ${Sen.Script.Executor.clock.duration.toFixed(3)}s`, Sen.Script.Definition.Console.Color.GREEN);
        return;
    }

    export function display_argument(argument: string | string[]): void {
        if (is_string(argument)) {
            Console.send(`${Sen.Kernel.Language.get("execution_argument")}:`, Definition.Console.Color.CYAN);
            if (Shell.is_gui) {
                Kernel.Console.print(`${argument}`);
            } else {
                Kernel.Console.print(`    ${argument}`);
            }
        } else {
            Console.send(`${Sen.Kernel.Language.get("execution_argument")}:`, Definition.Console.Color.CYAN);
            argument.forEach(function call_print(e): void {
                if (Shell.is_gui) {
                    Kernel.Console.print(e);
                } else {
                    Kernel.Console.print(`    ${e}`);
                }
            });
        }
        return;
    }

    export function execute<Argument extends Base>(argument: Argument, id: string, forward: Forward): string {
        let result: string = undefined!;
        try {
            run_as_module<Argument>(id, argument, forward);
        } catch (e: any) {
            result = Exception.make_exception(e);
            Console.error(result);
        }
        return result;
    }

    export function load_module<Argument extends Base>(argument: Argument): void {
        const modules: Map<bigint, string> = new Map<bigint, string>();
        const query = (
            callback: (([type, method]: [MethodType, RegExp], source: string) => boolean) | (([type, method]: [MethodType, ...Array<RegExp>], source: Array<string>) => boolean),
            filter: [MethodType, RegExp | Array<RegExp>],
            source: string | string[],
            method_name: string,
        ) => {
            if (callback(filter as [MethodType, RegExp], source as string & string[])) {
                modules.set(BigInt(modules.size) + 1n, method_name);
            }
            return;
        };
        methods.forEach(function process_module(worker, method_name): void {
            if (!worker.is_enabled) {
                return;
            }
            if (is_string(argument.source)) {
                query(test, worker.filter as [MethodType, RegExp], argument.source as string, method_name);
            }
            if (is_array(argument.source)) {
                query(test_array, worker.filter as [MethodType, RegExp], argument.source as string[], method_name);
            }
        });
        display_argument(argument.source as string | string[]);
        Console.send(`${Sen.Kernel.Language.get("execution_argument")}: ${Kernel.Language.get("js.input_an_method_to_start")}`, Definition.Console.Color.CYAN);
        modules.forEach(function print_statement(name: string, num: bigint): void {
            if (Shell.is_gui) {
                Kernel.Console.print(`${num}. ${Kernel.Language.get(name)}`);
            } else {
                Kernel.Console.print(`    ${num}. ${Kernel.Language.get(name)}`);
            }
        });
        const view: Array<bigint> = Array.from(modules.keys());
        switch (view.length) {
            case 0: {
                Console.error(Kernel.Language.get("js.argument_ignored"));
                break;
            }
            case 1: {
                execute<Argument>(argument, modules.get(view[0])!, Forward.DIRECT);
                break;
            }
            default: {
                const input_value: bigint = input_integer(view);
                execute<Argument>(argument, modules.get(input_value)!, Forward.DIRECT);
            }
        }
        return;
    }

    export type RequireModule = Record<string, unknown> & { method: string };

    export function is_valid_source<Argument extends Base>(argument: Argument, is_directory: boolean): void {
        if (argument.source === undefined) {
            argument.source = Console.path(Kernel.Language.get("input_argument"), is_directory ? "directory" : "file");
            return;
        }
        if (typeof argument.source !== "string") {
            delete argument.source;
            return is_valid_source(argument, is_directory);
        }
        if (is_directory && Kernel.FileSystem.is_file(argument.source as string)) {
            delete argument.source;
            return is_valid_source(argument, is_directory);
        }
        if (!is_directory && Kernel.FileSystem.is_directory(argument.source)) {
            delete argument.source;
            return is_valid_source(argument, is_directory);
        }
        return;
    }

    export function exchange_argument_value<T>(value: string): T {
        if (/^(((\d+)[f|n]))$/.test(value)) {
            if (value.endsWith("f")) {
                return Number(value.substring(0, value.length - 1)) as T;
            }
            return BigInt(value.substring(0, value.length - 1)) as T;
        }
        if (/(((true|false)))/i.test(value)) {
            return (value === "true") as T;
        }
        return value as T;
    }

    export function parse_argument<Argument extends Base & { source: Array<string> }>(argument: Argument, temporary: RequireModule): void {
        let raw = argument.source;
        for (let i = 0; i < raw.length; ++i) {
            if (raw[i].startsWith("-")) {
                temporary[raw[i++].slice(1)] = exchange_argument_value(raw[i]);
            }
        }
        return;
    }

    export function not_available_atlas_method(value: string): void {
        if (["popcap.atlas.split_by_resource_group", "popcap.atlas.split_by_res_info"].includes(value)) {
            throw new Error(Kernel.Language.get("script.cannot_execute_atlas_split_method"));
        }
        return;
    }

    export function forward<Argument extends Base>(argument: Argument): void {
        {
            const loader: RequireModule = { method: undefined! };
            parse_argument(argument as Argument & { source: Array<string> }, loader);
            if (loader.method !== undefined) {
                const method = loader.method;
                not_available_atlas_method(method);
                delete (loader as any).method;
                execute(loader as Argument, method, Forward.DIRECT);
                return;
            }
        }
        argument.source = (argument.source as Array<string>).map((e: string) => normalize(e));
        if ((argument.source as Array<string>).length > 1) {
            Console.send(`${Kernel.Language.get("js.make_host.argument_obtained")}:`, Definition.Console.Color.CYAN);
            (argument.source as Array<string>).forEach((e, i) => {
                Kernel.Console.print(`    ${i + 1}. ${e}`);
            });
            Console.send(format(`${Kernel.Language.get("js.obtained_argument")}:`, (argument.source as string).length), Definition.Console.Color.CYAN);
            if (Shell.is_gui) {
                Kernel.Console.print(`${1n}. ${Kernel.Language.get("js.process_whole")}`);
                Kernel.Console.print(`${2n}. ${Kernel.Language.get("js.process_in_queue")}`);
                Kernel.Console.print(`${3n}. ${Kernel.Language.get("js.process_in_script")}`);
                Kernel.Console.print(`${4n}. ${Kernel.Language.get("popcap.atlas.split_by_resource_group")}`);
                Kernel.Console.print(`${5n}. ${Kernel.Language.get("popcap.atlas.split_by_res_info")}`);
            } else {
                Kernel.Console.print(`    ${1n}. ${Kernel.Language.get("js.process_whole")}`);
                Kernel.Console.print(`    ${2n}. ${Kernel.Language.get("js.process_in_queue")}`);
                Kernel.Console.print(`    ${3n}. ${Kernel.Language.get("js.process_in_script")}`);
                Kernel.Console.print(`    ${4n}. ${Kernel.Language.get("popcap.atlas.split_by_resource_group")}`);
                Kernel.Console.print(`    ${5n}. ${Kernel.Language.get("popcap.atlas.split_by_res_info")}`);
            }
            const input: bigint = input_integer([1n, 2n, 3n, 4n, 5n]);
            switch (input) {
                case 1n: {
                    // to do
                    break;
                }
                case 2n: {
                    (argument.source as Array<string>).forEach(function process_package(e: string) {
                        load_module({ source: e });
                    });
                    break;
                }
                case 3n: {
                    // to do
                    break;
                }
                case 4n: {
                    execute<Argument>(argument, "popcap.atlas.split_by_resource_group", Forward.DIRECT);
                    break;
                }
                case 5n: {
                    execute<Argument>(argument, "popcap.atlas.split_by_res_info", Forward.DIRECT);
                    break;
                }
            }
        } else {
            (argument.source as Array<string>).forEach(function process_package(e: string) {
                load_module({ source: e });
            });
        }
        return;
    }

    export function basic_batch<
        Argument extends Sen.Script.Executor.Base,
        BatchArgument extends Sen.Script.Executor.Base & { directory: string },
        AsyncArgument extends Sen.Script.Executor.Base,
        Configuration extends Sen.Script.Executor.Configuration,
    >(thiz: MethodExecutor<Argument, BatchArgument, AsyncArgument, Configuration>, argument: BatchArgument, is_directory: boolean, other?: Record<string, unknown>): void {
        let callback: (source: string) => boolean = is_directory ? Kernel.FileSystem.is_directory : Kernel.FileSystem.is_file;
        const files: Array<string> = Sen.Kernel.FileSystem.read_directory(argument.directory).filter((path: string) => callback(path) && thiz.filter[1].test(path));
        files.forEach((source: string) => thiz.direct_forward({ source: source as string, ...other } as any));
        Sen.Script.Console.finished(Sen.Script.format(Sen.Kernel.Language.get("batch.process.count"), files.length));
        return;
    }
}
