namespace Sen.Script.Executor.Methods.PopCap.CryptData.Decrypt {
	/**
	 * Argument for the current method
	 */

	export interface Argument extends Executor.Base {
		source: string;
		destination?: string;
		key?: string;
	}

	/**
	 * Argument for batch method
	 */

	export interface BatchArgument extends Executor.Base {
		directory: string;
		key?: string;
	}

	/**
	 * Configuration file if needed
	 */

	export interface Configuration extends Executor.Configuration {
		key: '?' | string;
	}

	/**
	 * ----------------------------------------------
	 * JavaScript forward method, this method need
	 * to be evaluated during script loading time
	 * ----------------------------------------------
	 */

	export function forward(): void {
		return push_as_module<
			Methods.PopCap.CryptData.Decrypt.Argument,
			Methods.PopCap.CryptData.Decrypt.BatchArgument,
			Methods.PopCap.CryptData.Decrypt.Configuration
		>({
			id: 'popcap.crypt_data.decrypt',
			configuration_file: Home.query(
				'~/Executor/Configuration/popcap.crypt_data.decrypt.json',
			),
			direct_forward(argument: Argument): void {
				is_valid_source(argument, false);
				Console.obtained(argument.source);
				defined_or_default<Argument, string>(
					argument,
					'destination',
					`${Kernel.Path.except_extension(argument.source)}.bin`,
				);
				check_overwrite(argument as { destination: string }, 'file');
				Console.output(argument.destination!);
				load_string(
					argument,
					'key',
					this.configuration,
					Kernel.Language.get('popcap.crypt_data.decrypt.key'),
				);
				clock.start_safe();
				Kernel.Support.PopCap.CryptData.decrypt_fs(
					argument.source,
					argument.destination!,
					argument.key!,
				);
				clock.stop_safe();
				return;
			},
			is_enabled: true,
			configuration: undefined!,
			filter: ['file', /(.+)\.bin$/i],
			option: 21n,
		});
		return;
	}
}

Sen.Script.Executor.Methods.PopCap.CryptData.Decrypt.forward();
