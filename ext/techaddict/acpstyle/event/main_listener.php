<?php
/**
 * Carbon ACP: dark Control Panel styling matching the Carbon board theme.
 *
 * @license GPL-2.0-only
 */

namespace techaddict\acpstyle\event;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class main_listener implements EventSubscriberInterface
{
	/** @var \phpbb\template\template */
	protected $template;

	/** @var string */
	protected $phpbb_root_path;

	public function __construct(\phpbb\template\template $template, $phpbb_root_path)
	{
		$this->template = $template;
		$this->phpbb_root_path = $phpbb_root_path;
	}

	public static function getSubscribedEvents()
	{
		return array(
			'acp_overall_header_head_append' => 'add_stylesheet',
		);
	}

	public function add_stylesheet($event)
	{
		$this->template->assign_var(
			'TECHADDICT_ACP_CSS',
			$this->phpbb_root_path . 'ext/techaddict/acpstyle/styles/all/theme/acp.css?v=1'
		);
	}
}
