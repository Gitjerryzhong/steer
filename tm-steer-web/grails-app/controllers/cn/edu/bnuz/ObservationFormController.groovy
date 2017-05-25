package cn.edu.bnuz

import org.springframework.security.access.prepost.PreAuthorize

@PreAuthorize('hasAuthority("PERM_SUPERVISOR_WRITE")')
class ObservationFormController {

    def index() { }
}
